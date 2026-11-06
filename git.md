Branch_A based on main
Branch_B based on Branch_A
Branch_A was merged
Branch_B says "The base branch was changed."

git checkout main
git pull
git checkout Branch_B
git rebase --onto main Branch_A
git push --force-with-lease

git fetch origin
git switch Branch_B
git rebase --onto origin/main Branch_A
git push --force-with-lease origin Branch_B
