class VcsRepositoryCache extends FolderCache {
    repositoryMgr := ""

    __New(repositoryMgr, tmpDir, stateObj, parentDir, cacheDirName := "", existsSubPath := "") {
        this.repositoryMgr := repositoryMgr
        super.__New(tmpDir, stateObj, parentDir, cacheDirName, existsSubPath)
    }

    CacheDirExists(path) {
        return super.CacheDirExists(path) && this.repositoryMgr.IsVcsDir(this.GetCachePath(path))
    }

    GetVcsRemoteUrl(path) {
        return this.repositoryMgr.LookupRepositoryUrl(this.GetCachePath(path))
    }

    /**
     * Caches a repository from the provided VCS url.
     */
    WriteItemAction(path, url := "", ref := "") {
        return this.CloneVcsRepo(path, url, ref, true)
    }

    ImportItemFromUrl(path, url := "", ref := "") {
        return this.CloneVcsRepo(path, url, ref, true)
    }

    CloneVcsRepo(path, url := "", ref := "", overwrite := false) {
        if (url == "") {
            url := path
            path := this.ConvertUrlToPathName(url)
        }

        this.CreateCacheDir(path)
        path := this.GetCachePath(path)

        repository := this.repositoryMgr.GetRepositoryInstance(path, url)
        repository.CloneRepository(ref, overwrite)

        this.stateObj.SetItem(path)

        return path
    }
}
