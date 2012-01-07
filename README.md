DESCRIPTION
===========

Sets up an APT repository suitable for using the reprepro tool to manage distributions and components.

REQUIREMENTS
============

Platform: Debian or Ubuntu.

Requires Chef 0.8.x+, client/server. Does not work with Chef Solo due to data bag use.

You'll need to generate the PGP key separately and provide the data in the databag.

USAGE
=====

Attributes
----------

Attributes in this cookbook are set via the default recipe with data from the data bag. The following attributes are used, in the `reprepro` namespace.

* `fqdn` - the fqdn that would go in sources.list
* `description` - a description of the repository
* `pgp_email` - the email address of the pgp key
* `pgp_fingerprint` - the finger print of the pgp key

Data Bag
--------

Create a data bag to store the repository information. 

    {
      "id" : "main",
      "fqdn":"debian.acme.com",
      "description": "Debian repository",
      "repo_dir": "/srv/reprepro/zenexity-repo/",
      "incoming": "/srv/reprepro/zenexity-incoming/",
      "pgp" :{
        "email": "packages@acme.com",
        "public": "",
      },
      "codenames" : [
        {"codename": "squeeze", "suite":"stable", "aliases":["squeeze-security"]}, 
        {"codename": "wheezy", "suite":"testing", "aliases":[]}, 
        {"codename": "sid", "suite":"unstable", "aliases":[]}],
      "architectures" : ["source", "i386", "amd64" ],
      "pulls" : {
        "component":"main",
        "name": "sid",
        "from": "sid"
        },
    "ssh-keys":[],
    "access":[]
    }

LICENSE AND AUTHOR
==================

Author: Joshua Timberman (<joshua@opscode.com>)
Author: Arthur gautier (<aga@zenexity.com>)

Copyright 2010, Opscode, Inc.
Copyright 2011, Zenexity

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

vim: ts=2 sw=2 et ft=markdown:
