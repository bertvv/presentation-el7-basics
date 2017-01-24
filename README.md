# Basic commands for Enterprise Linux 7

This repository contains the slides and code examples for my talk at [CentOS Dojo Brussels, Februari 2017](https://wiki.centos.org/Events/Dojo/Brussels2017). The slides can be viewed here: <https://bertvv.github.io/presentation-el7-basics/>.

## Compiling the slides

The slides were created using [Pandoc](http://pandoc.org/) The [source file](basic-commands-el7.md) in [Markdown](https://daringfireball.net/projects/markdown/) was converted into a [Reveal js](http://lab.hakim.se/reveal-js/#/) presentation. A [Makefile](Makefile) is provided to automate the build process.

## Running the code

During the presentation, I use the included Vagrant environment as a demo. To recreate the setup, do:

```ShellSession
$ git clone https://github.com/bertvv/presentation-el7-basics.git
$ cd presentation-el7-basics
$ vagrant status
Current machine states:

db                        not created (virtualbox)
web                       not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
$ vagrant up
```

The setup consists of two VirtualBox VMs:

| Host  | IP            | Service              |
| :---  | :---          | :---                 |
| `web` | 192.168.56.72 | http, https (Apache) |
| `db`  | 192.168.56.73 | mysql (MariaDB)      |

- On `web`, a PHP app runs a query on the `db`
- `db` is set up correctly, `web` is not

Throughout the presentation, we'll be fixing issues with `web`.

## License

This work is licensed under a [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/). Source code of the examples is licensed under the [2-clause BSD License](LICENSE.md).

