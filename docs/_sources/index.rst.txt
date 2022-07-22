``rules_ll`` Documentation
--------------------------

This is the documentation for ``rules_ll``.

Guides
======

.. toctree::
   :maxdepth: 1
   :caption: Guides

   guides/clang_tidy

Public API
==========

Example projects can be found at `<https://github.com/eomii/rules_ll/tree/main/examples>`_.

.. toctree::
   :maxdepth: 2
   :caption: Public API

   defs

Private API
===========

These are the internal functions used in ``rules_ll``, except for
``//ll:init.bzl``, whose stardoc build is currently broken.

.. toctree::
   :maxdepth: 2
   :caption: Private API

   actions
   args
   attributes
   compilation_database
   defs
   driver
   environment
   inputs
   internal_functions
   ll
   os
   outputs
   providers
   toolchain
   tools
   transitions
