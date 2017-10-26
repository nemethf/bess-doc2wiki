# bess-doc2wiki
Automatically regenerate bess documentation and update the wiki page

# Installation

1. Clone `bess-doc2wiki`, `bess`, `bess.wiki`, and [Justine Sherry's
`protoc-gen-doc`](https://github.com/justinemarie/protoc-gen-doc)
repositories into a common directory.  `bess` and `bess.wiki` should
not deviate from origin master, i.e., there should be no local
development there.

2. Compile protoc-gen-doc

3. To automatically regenerate the wiki page after each commit to the
   master you can

    (i) set up a web-hook in the github project page that runs `update.sh`,
    or

    (ii) "watch" the project, and extend your .procmailrc file:
    ```
    :0
    * ^List-Archive:.https://github.com/NetSys/bess
    {
        :0 cB: bess.lock
        * ^Merged.#[0-9]
        | $HOME/src/bess-doc2wiki/update.sh
    }
    ```

It seems anyone can edit the wiki using github's the web interface,
but `git push` is restricted to those how have write access to the
project.  Therefore, my automatically updated version of the
documentation is
[here](https://github.com/nemethf/bess/wiki/Built-In-Modules-and-Ports)
