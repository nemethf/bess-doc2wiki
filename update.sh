#!/bin/bash
# Automatically regenerate bess documentation and update the wiki page
# Copyright (C) 2017-2020 Felicián Németh
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BESS_DIR="$DIR"/../bess
BESS_WIKI_DIR="$DIR"/../bess.wiki
PROTOC_DIR="$DIR"/../protoc-gen-doc
WIKI_PAGE=Built-In-Modules-and-Ports
header_file=$(mktemp)
quiet=-q

cd "$BESS_WIKI_DIR"
git reset $quiet --hard origin/master
git pull $quiet origin master

cd "$BESS_DIR"
git pull $quiet origin master
bess_rev=$(git describe --dirty --always --tags)


PATH=$PATH:"$PROTOC_DIR"
cd "$BESS_DIR"/protobuf

cat >"$header_file" <<'EOF'
__This text is auto-generated from comments in the module code.  To edit the contents of this page, please edit the comments in `bess/protobuf` in the main BESS repository.__  To see how this page is automatically re-generated after each commit, check out [this repository](https://github.com/nemethf/bess-doc2wiki).
EOF

ODIR="$BESS_DIR"/protobuf/protoc-out

mkdir -p $ODIR
docker run --rm -v "$ODIR":/out -v $(pwd):/protos:ro \
       pseudomuto/protoc-gen-doc --doc_opt=markdown,Modules.md \
       module_msg.proto util_msg.proto
cat "$header_file" "$ODIR"/Modules.md \
    | sed 's/Command/\./g' | sed 's/Arg/()/g' > Modules.md.out
"$DIR/fix_markdown" Modules.md.out "$BESS_WIKI_DIR"/$WIKI_PAGE.md
rm -f "$header_file"

cd "$BESS_WIKI_DIR"
if [[ $(git status --porcelain) ]]; then
    git add $WIKI_PAGE.md
    git commit -m "Regenerate $WIKI_PAGE for $bess_rev"
    git push $quiet origin master
fi
