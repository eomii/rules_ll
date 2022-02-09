"""Sphinx config file."""

# -- Project information -----------------------------------------------------

project = 'rules_ll'
copyright = '2021, The Qogecoin Authors'
author = 'The Qogecoin Authors'

# The full version, including alpha/beta/rc tags
release = '0.0.0-rc0'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.githubpages',
    'myst_parser',
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
html_theme = 'sphinx_book_theme'

html_title = 'rules_ll Documentation'

html_theme_options = {
    'extra_navbar': '',
    'use_download_button': False,
    'use_fullscreen_button': False,

    'repository_url': 'https://github.com/qogecoin/rules_ll',
    'use_repository_button': True,
}
