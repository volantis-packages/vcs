class GitRepository extends VcsRepositoryBase {
    _repositoryTypeConfig := Map(
        "gitCommand", "git"
    )

    GitCommand(cmd, args := "") {
        tmpFile := A_Temp . "\git_output_" . A_Now . ".txt"
        fullCmd := A_ComSpec . "/c `"" . this._repositoryTypeConfig["gitCommand"] . "`" " . cmd . " " . args . " > " . tmpFile

        result := RunWait(fullCmd, this.Path, "Hide")
        val := false

        if (FileExist(tmpFile)) {
            val := FileRead(tmpFile)
            FileDelete(tmpFile)
        } else {
            throw DataException("Git command failed: " . fullCmd . "`nResult: " . result)
        }

        return val
    }

    _GetRemoteUrl(remote := "origin") {
        return this.GitCommand("config", "--get remote." . remote . ".url")
    }

    _ResetLocalRepository() {
        this.GitCommand("reset", "--hard")
        this.GitCommand("clean", "-fxd")
    }

    _GetUncommittedChanges() {
        filesStr := this.GitCommand("ls-files", "--others --modified")
        return StrSplit(filesStr, "`n")
    }

    _CloneRepository(ref := "") {
        argsStr := this.Url . " " . this.Path . " -q"

        if (ref != "") {
            argsStr .= " -b " . ref
        }

        this.GitCommand("clone", argsStr)
    }

    _CheckoutRef(ref) {
        this.GitCommand("checkout", ref)
    }

    _CreateBranch(name, fromRef := "") {
        if (fromRef != "") {
            this.GitCommand("checkout", fromRef)
        }

        this.GitCommand("checkout", "-b " . name)
    }

    _CommitChanges(message, files := "") {
        if (files == "") {
            files := "-A"
        }

        if (files.HasBase(Array.Prototype)) {
            filesStr := ""

            for , fileStr in files {
                if (filesStr) {
                    filesStr .= " "
                }

                filesStr .= fileStr
            }

            files := filesStr
        }

        this.GitCommand("add", files)
        this.GitCommand("commit", "-m " . message)
    }

    _UpdateLocalRepository(ref := "") {
        if (ref != "") {
            this.GitCommand("checkout", ref)
        }

        this.GitCommand("pull")
    }

    _GetFileFromRef(ref, path) {
        return this.GitCommand("show", ref . ":" . path)
    }

    _GetBranches(pattern := "", includeRemote := true) {
        gitOptions := ""

        if (includeRemote) {
            gitOptions := "-a"
        }

        if (pattern != "") {
            gitOptions .= " --list " . pattern
        }

        output := this.GitCommand("branch", gitOptions)
        remotePrefix := "remotes/origin/"
        branches := []

        for , branchName in StrSplit(output, "`n") {
            if (InStr(branchName, remotePrefix) == 1) {
                branchName := SubStr(branchName, StrLen(remotePrefix) + 1)
            }

            if (!InStr(branchName, "/")) {
                exists := false
                for , existingBranch in branches {
                    if (existingBranch == branchName) {
                        exists := true
                        break
                    }
                }

                if (!exists) {
                    branches.Push(branchName)
                }
            }
        }

        return branches
    }

    _GetTags(pattern := "", includeRemote := true) {
        if (includeRemote) {
            this.GitCommand("fetch", "--all --tags")
        }

        gitOptions := "-l"

        if (pattern) {
            gitOptions .= " " . pattern
        }

        output := this.GitCommand("tag", gitOptions)
        return StrSplit(output, "`n")
    }
}
