class VcsRepositoryBase {
    _path := ""
    _url := ""
    _typeDetector := ""
    _repositoryTypeConfig := Map()

    Path {
        get => this._path
    }

    Url {
        get => this._url
    }

    __New(path, url, repositoryTypeDetector, repositoryTypeConfig := "") {
        this._path := path
        this._url := url
        this._typeDetector := repositoryTypeDetector

        if (repositoryTypeConfig != "") {
            for key, value in repositoryTypeConfig {
                this._repositoryTypeConfig[key] := value
            }
        }
    }

    LocalRepositoryExists() {
        return !!DirExist(this._path) && this._typeDetector.LocalPathMatches(this._path)
    }

    CloneRepository(ref := "", overwrite := false) {
        if (this.LocalRepositoryExists()) {
            if (overwrite) {
                DirDelete(this._path)
            } else {
                return
            }
        }

        this._CloneRepository(ref)

        if (ref) {
            this.CheckoutRef(ref)
        }
    }

    DeleteLocalRepository() {
        if (this.LocalRepositoryExists()) {
            DirDelete(this._path)
        }
    }

    CheckoutRef(ref) {
        if (!this.LocalRepositoryExists()) {
            throw DataException("Local repository does not exist")
        }

        if (!this.LocalRepositoryIsClean()) {
            throw DataException("Local repository directory is not clean")
        }

        this._CheckoutRef(ref)
    }

    GetUncommittedChanges() {
        if (!this.LocalRepositoryExists()) {
            throw DataException("Local repository does not exist")
        }

        return this._GetUncommittedChanges()
    }

    LocalRepositoryIsClean() {
        uncommittedChanges := this.GetUncommittedChanges()

        return (uncommittedChanges == "" || uncommittedChanges.Length > 0)
    }

    UpdateLocalRepository(ref := "") {
        if (!this.LocalRepositoryExists()) {
            this.CloneRepository(ref)
        }

        if (ref) {
            this.CheckoutRef(ref)
        }

        this._UpdateLocalRepository(ref)
    }

    /**
     * If files is an empty string, all modified files will be committed.
     * Otherwise it should be a file glob or an array of file paths or globs.
     */
    CommitChanges(message, files := "") {
        if (!this.LocalRepositoryExists()) {
            throw DataException("Local repository does not exist")
        }

        this._CommitChanges(message, files)
    }

    ResetLocalRepository() {
        if (!this.LocalRepositoryExists()) {
            throw DataException("Local repository does not exist")
        }

        this._ResetLocalRepository()
    }

    GetRemoteUrl(remote := "origin") {
        if (!this.LocalRepositoryExists()) {
            throw DataException("Local repository does not exist")
        }

        return this._GetRemoteUrl(remote)
    }

    CreateBranch(name, fromRef := "") {
        if (!this.LocalRepositoryExists()) {
            throw DataException("Local repository does not exist")
        }

        this._CreateBranch(name, fromRef)
    }

    _CreateBranch(name, fromRef := "") {
        throw MethodNotImplementedException("VcsRepositoryBase", "_CreateBranch")
    }

    _GetRemoteUrl(remote := "origin") {
        throw MethodNotImplementedException("VcsRepositoryBase", "_GetRemoteUrl")
    }

    _ResetLocalRepository() {
        throw MethodNotImplementedException("VcsRepositoryBase", "_ResetLocalRepository")
    }

    _GetUncommittedChanges() {
        throw MethodNotImplementedException("VcsRepositoryBase", "_GetUncommittedChanges")
    }

    _CloneRepository(ref := "") {
        throw MethodNotImplementedException("VcsRepositoryBase", "_CloneRepository")
    }

    _CheckoutRef(ref) {
        throw MethodNotImplementedException("VcsRepositoryBase", "_CheckoutRef")
    }

    _CommitChanges(message, files := "") {
        throw MethodNotImplementedException("VcsRepositoryBase", "_CommitChanges")
    }

    _UpdateLocalRepository(ref := "") {
        throw MethodNotImplementedException("VcsRepositoryBase", "_UpdateLocalRepository")
    }

    GetFileFromRef(ref, path) {
        if (!this.LocalRepositoryExists()) {
            throw DataException("Local repository does not exist")
        }

        return this._GetFileFromRef(ref, path)
    }

    _GetFileFromRef(ref, path) {
        throw MethodNotImplementedException("VcsRepositoryBase", "_GetFileFromRef")
    }

    GetBranches(pattern := "", includeRemote := true) {
        if (!this.LocalRepositoryExists()) {
            throw DataException("Local repository does not exist")
        }

        return this._GetBranches(pattern, includeRemote)
    }

    _GetBranches(pattern := "", includeRemote := true) {
        throw MethodNotImplementedException("VcsRepositoryBase", "_GetBranches")
    }

    GetTags(pattern := "", includeRemote := true) {
        if (!this.LocalRepositoryExists()) {
            throw DataException("Local repository does not exist")
        }

        return this._GetTags(pattern, includeRemote)
    }

    _GetTags(pattern := "", includeRemote := true) {
        throw MethodNotImplementedException("VcsRepositoryBase", "_GetTags")
    }
}
