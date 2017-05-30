Releasing
=========

Note: This may vary based on your distribution mechanism.  Assuming CocoaPods:

 0. Bump the version to reflect a new version.
 1. Change the version in `RxState.podspec` to reflect a new version.
 2. Update the `CHANGELOG.md` for the impending release.
 3. Update the `README.md` with the new version.
 4. `git commit -am "Release X.Y.Z."` (where X.Y.Z is the new version)
 5. `git tag "X.Y.Z"` (where X.Y.Z is the new version)
 6. `git push --tags`
 7. `pod trunk push RxState.podspec`
 
