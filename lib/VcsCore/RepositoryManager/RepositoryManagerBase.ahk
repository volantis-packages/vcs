class RepositoryManagerBase {
    repositoryTypes := Map()
    repositoryDetectors := Map()
    repositoryInstances := Map()
    repositoryTypeConfig := Map()

    RegisterRepositoryType(typeKey, repositoryClass, repositoryDetectorObj, repositoryTypeConfig := "") {
        this.repositoryTypes[typeKey] := repositoryClass
        this.repositoryDetectors[typeKey] := repositoryDetectorObj
        this.repositoryTypeConfig[typeKey] := repositoryTypeConfig
    }

    GetRepositoryInstance(localPath, url := "", repositoryType := "") {
        if (!localPath && !url) {
            throw DataException("Either localPath or url must be provided")
        }

        if ((!localPath || !DirExist(localPath) && !url && !repositoryType)) {
            throw DataException("Unable to determine repository type or url")
        }

        if (!this.repositoryInstances.Has(localPath)) {
            if (repositoryType == "") {
                repositoryType := this.GetRepositoryType(localPath, url)
            }

            if (repositoryType == "") {
                throw DataException("Unable to determine repository type")
            }

            repositoryClass := this.repositoryTypes[repositoryType]

            if (!repositoryClass) {
                throw DataException("Repository class unknown for type: " . repositoryType)
            }

            this.repositoryInstances[localPath] := %repositoryClass%(
                localPath,
                url,
                this.repositoryDetectors[repositoryType],
                this.repositoryTypeConfig[repositoryType]
            )
        }

        return this.repositoryInstances[localPath]
    }

    LookupRepositoryUrl(localPath, repositoryType := "", remote := "origin") {
        repository := this.GetRepositoryInstance(localPath, "", repositoryType)
        return repository.GetRemoteUrl(remote)
    }

    IsVcsDir(localPath) {
        if (!DirExist(localPath)) {
            return false
        }

        repositoryType := this.GetRepositoryType(localPath)

        return repositoryType != ""
    }

    GetRepositoryType(localPath, url := "", allowPossibleMatches := false) {
        typeFromLocalPath := this.GetRepositoryTypeFromLocalPath(localPath, allowPossibleMatches)
        typeFromUrl := []

        if (typeFromLocalPath != "" && Type(typeFromLocalPath) == "String") {
            if (!allowPossibleMatches) {
                return typeFromLocalPath
            }
            typeFromLocalPath := [typeFromLocalPath]
        }

        if (url) {
            typeFromUrl := this.GetRepositoryTypeFromUrl(url, allowPossibleMatches)

            if (typeFromUrl != "" && Type(typeFromUrl) == "String") {
                if (!allowPossibleMatches) {
                    return typeFromUrl
                }

                typeFromUrl := [typeFromUrl]
            }
        }


        typeMatches := []
        typeMatch := ""

        for idx, type in typeFromLocalPath {
            if (url == "") {
                typeMatches.Push(type)
            } else {
                for innerIdx, innerType in typeFromUrl {
                    if (type == innerType) {
                        typeMatches.Push(type)
                        break
                    }
                }
            }
        }

        if (!typeMatch && typeMatches.Length == 1) {
            typeMatch := typeMatches[1]
        } else if (!typeMatch && allowPossibleMatches) {
            typeMatch := typeMatches
        }

        return typeMatch
    }

    /**
     * If possible matches are allowed, can be an array of possible types.
     * Otherwise it will either be a type key or an empty string.
     */
    GetRepositoryTypeFromLocalPath(localPath, allowPossibleMatches := false) {
        maybeMatches := []
        match := ""

        for typeKey, repositoryDetector in this.repositoryDetectors {
            result := repositoryDetector.LocalPathMatches(localPath)

            if (result > 0) {
                match := typeKey
                break
            } else if (result == 0) {
                maybeMatches.Push(typeKey)
            }
        }

        if (match == "" && allowPossibleMatches) {
            return maybeMatches
        }

        return match
    }

    GetRepositoryTypeFromUrl(url, allowPossibleMatches := false) {
        maybeMatches := []
        match := ""

        for typeKey, repositoryDetector in this.repositoryDetectors {
            result := repositoryDetector.UrlMatches(url)

            if (result > 0) {
                match := typeKey
                break
            } else if (result == 0) {
                maybeMatches.Push(typeKey)
            }
        }

        if (match == "" && allowPossibleMatches) {
            return maybeMatches
        }

        return match
    }
}
