#!/usr/bin/env python3

import sys
import os
import json
import glob
import fnmatch
from pathlib import Path

def detectChangesFromPrevCommit(monoRepositoryRootPath, gitRepositoryRootPath):
    branch = os.popen(f"git rev-parse --abbrev-ref HEAD").read().strip()
    if branch == "master":
        changedFiles = os.popen(f"git diff --name-only HEAD^").read().strip().split("\n")
    else:
        changedFiles = os.popen(f"git diff --name-only origin/master").read().strip().split("\n")
    changedFiles = [os.path.join(gitRepositoryRootPath, f) for f in changedFiles]
    changedFiles = [f for f in changedFiles if f.startswith(monoRepositoryRootPath)]
    changedFiles = [ os.path.relpath(f, monoRepositoryRootPath) for f in changedFiles ]

    return changedFiles

def detectChangedFiles(dir):
    gitRepositoryRootPath = os.popen("git rev-parse --show-toplevel").read().strip()
    monoRepositoryRootPath = dir
    changedFiles = os.popen(f"git status --porcelain=v1 --untracked-files").read().strip().split("\n")
    changedFiles = [f[2:] for f in changedFiles]
    changedFiles = [os.path.join(gitRepositoryRootPath, f) for f in changedFiles]
    changedFiles = [f for f in changedFiles if f.startswith(monoRepositoryRootPath)]
    changedFiles = [ os.path.relpath(f, monoRepositoryRootPath) for f in changedFiles ]
   
    if len(changedFiles) == 0:
        # Try to fallback to prev commit diff.
        changedFiles = detectChangesFromPrevCommit(monoRepositoryRootPath, gitRepositoryRootPath)

    return changedFiles

class Project:
    def __init__(self, path):
        with open(path) as f:
            self.projectJSON = json.load(f)
        self.name = self.projectJSON['name']
        self.dir = Path(path).parent
        self.dependencies = []
        self.dependents = []
        self.hasFileChanges = False
        self.hasDependencyChanges = False

    def linkToDependencies(self, projects):
        for id in self.projectJSON.get('dependencies', []):
            if not id in projects:
                raise Exception(f"Project \"{self.name}\" depends on \"{id}\" which is not found")
            
            dependency = projects[id]
            self.dependencies.append(dependency)
            dependency.dependents.append(self)

    def visit(self, visited):
        if self.name in visited:
            raise Exception(f"Dependency loop detected nearby \"{self.name}\"")

        visited[self.name] = self
        for dependency in self.dependencies:
            dependency.visit(visited)
        visited.pop(self.name)
        
    def matchChangedFiles(self, changedFiles):
        self.hasFileChanges = False
        for pattern in self.projectJSON.get('glob', []):
            filtered = fnmatch.filter(changedFiles, pattern)
            if len(filtered) > 0:
                self.hasFileChanges = True
                self.markSubtreeAsModified()
                return
        
    def markSubtreeAsModified(self):
        for dependent in self.dependents:
            dependent.hasDependencyChanges = True
            dependent.markSubtreeAsModified()

    def hasChanges(self):
        return self.hasFileChanges or self.hasDependencyChanges

    def run(self, task, args):
        if not task in self.projectJSON['tasks']:
            return

        command = self.projectJSON['tasks'][task]
        command = f"{command} {' '.join(args)}".strip()

        width = os.get_terminal_size().columns
        header = f"--[ {self.name}: {task} ]--"
        dashes = '-' * (width - len(header))
        print(f"\033[0;33m{header}{dashes}\033[0m")

        os.system(f"cd {self.dir} && {command}")

class Workspace:
    def __init__(self, dir):
        # Load all projects
        self.projects = []
        self.projectsByName = {}

        for projectJSON in glob.glob('**/project.json', root_dir=dir, recursive=True):
            project = Project(projectJSON)
            self.projects.append(project)
            self.projectsByName[project.name] = project

        # Link dependencies
        for project in self.projects:
            project.linkToDependencies(self.projectsByName)
        
        # Check for dependency loops
        visited = {}
        for project in self.projects:
            project.visit(visited)

        # Detect out-of-date projects
        changedFiles = detectChangedFiles(dir)
        for project in self.projects:
            project.matchChangedFiles(changedFiles)

    def run(self, selector, task, args):
        projects = self.topologicalSort()
        for project in [p for p in projects if selector(p)]:
            project.run(task, args)

    def topologicalSort(self):
        output = []
        dependencyCounters = {}
        roots = []
        
        for project in self.projects:
            if len(project.dependencies) == 0:
                roots.append(project)
            else:
                dependencyCounters[project] = len(project.dependencies)

        while len(roots) > 0:
            nextRoots = []
            for root in roots:
                output.append(root)

                for dependent in root.dependents:
                    dependencyCounters[dependent] -= 1
                    if dependencyCounters[dependent] == 0:
                        nextRoots.append(dependent)
            roots = nextRoots 

        return output

def selectOneProject(workspace, name):
    if not name in workspace.projectsByName:
        raise Exception(f"Project \"{name}\" not found")
    return [workspace.projectsByName[name]]

def executeListCommand():
    def printTableRow(marker, name, hasFileChanges, hasDependencyChanges):
        print(f"{marker.ljust(1)} {name.ljust(30)} {hasFileChanges.ljust(30)} {hasDependencyChanges.ljust(30)}")
   
    def boolToStr(value):
        return "YES" if value else "NO"
    
    printTableRow("", "PROJECT", "HAS FILE CHANGES", "HAS DEPENDENCY CHANGES")
    workspace = Workspace(os.getcwd())
    for project in workspace.projects:
        printTableRow("*" if project.hasChanges() else "", project.name, boolToStr(project.hasFileChanges), boolToStr(project.hasDependencyChanges))

def executeProjectCommand(args):
    if len(args) < 1:
        print("Missing <project> argument")
        exit(1)

    workspace = Workspace(os.getcwd())
    for name in args:
        if not name in workspace.projectsByName:
            print(f"Project \"{name}\" not found")
            exit(1)

        project = workspace.projectsByName[name]
        print(f"Project: {project.name}")
        print(f"  Directory: {project.dir}")
        print(f"  Dependencies: {', '.join([d.name for d in project.dependencies])}")
        print(f"  Dependents: {', '.join([d.name for d in project.dependents])}")
        print(f"  Has file changes: {project.hasFileChanges}")
        print(f"  Has dependency changes: {project.hasDependencyChanges}")

def executeAllCommand(args):
    if len(args) < 1:
        print("Missing <task> argument")
        exit(1)

    task = args[0]
    args = args[1:]
    
    workspace = Workspace(os.getcwd())
    workspace.run(lambda x: True, task, args)

def executeModifiedCommand(args):
    if len(args) < 1:
        print("Missing <task> argument")
        exit(1)

    task = args[0]
    args = args[1:]
    
    workspace = Workspace(os.getcwd())
    workspace.run(lambda x: x.hasChanges(), task, args)
    
def executeRunCommand(args):
    if len(args) < 1:
        print("Missing <project> argument")
        exit(1)
    if len(args) < 2:
        print("Missing <task> argument")
        exit(1)

    name = args[0]
    task = args[1]
    args = args[2:]
    
    workspace = Workspace(os.getcwd())
    workspace.run(lambda x: x.name == name, task, args)

def printUsage():
    print("Usage: adhoc <command> [args...]")
    print("Commands:")
    print("  run <project> <task> [args...]")
    print("  all <task> [args...]")
    print("  modified <task> [args...]")
    print("  ls")
    print("  project <project>")

if len(sys.argv) < 2:
    printUsage()
    exit(1)

match sys.argv[1]:
    case "?", "h", "help", "-h", "--help":
        # adhoc help
        printUsage()

    case "ls":
        # adhoc ls
        executeListCommand()

    case "project":
        # adhoc <project>...
        executeProjectCommand(sys.argv[2:])

    case "all":
        # adhoc all <task> [args...]
        executeAllCommand(sys.argv[2:])

    case "modified":
        # adhoc modified <task> [args...]
        executeModifiedCommand(sys.argv[2:])

    case "run":
        # adhoc run <project> <task> [args...]
        executeRunCommand(sys.argv[2:])
        
    case _:
        print(f"Unknown command: {sys.argv[1]}")
        exit(1)
