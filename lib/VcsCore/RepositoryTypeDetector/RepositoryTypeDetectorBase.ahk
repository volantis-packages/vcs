class RepositoryTypeDetectorBase {
    _typeKey := ""
    _localSubPath := ""
    _localSubPathType := "directory"
    _urlSuffix := ""

    __New(typeKey, urlSuffix, localSubPath, localSubPathType := "directory") {
        this._typeKey := typeKey
        this._localSubPath := localSubPath
        this._localSubPathType := localSubPathType
        this._urlSuffix := urlSuffix
    }

    /**
     * Return 0 if unknown, 1 if a definite match, and -1 if a definite mismatch.
     */
    UrlMatches(url) {
        if (this._urlSuffix == "") {
            return 0
        }

        if (SubStr(url, -StrLen(this._urlSuffix)) == this._urlSuffix) {
            return 1
        }

        return -1
    }

    /**
     * Return 0 if unknown, 1 if a definite match, and -1 if a definite mismatch.
     */
    LocalPathMatches(localPath) {
        if (!DirExist(localPath)) {
            return 0
        }

        isEmpty := true
        Loop Files localPath . "\*.*", "FD"
        {
            isEmpty := false
            break
        }

        if (isEmpty) {
            return 0
        }

        if (this._localSubPathType == "directory") {
            if (DirExist(localPath . "\" . this._localSubPath)) {
                return 1
            } else {
                return -1
            }
        } else if (this._localSubPathType == "file") {
            if (FileExist(localPath . "\" . this._localSubPath)) {
                return 1
            } else {
                return -1
            }
        } else {
            return 0
        }
    }
}
