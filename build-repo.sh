!#/bin/bash

set -x

echo "# new-concept" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M develop
git remote add origin https://github.com/weihuang-jedi/new-concept.git
git push -u origin develop

