Substance-Shell
===============

This project provides an alternative to the `brackets-shell` project.
The main difference lies in the choice of build-tool: rake instead of grunt.

Moreover we try to draw a more clear line between the CEF source code, particularly
the `cefclient` application, and own customizations.
Similar to `Brackets` we base the application shell on the example code of the `cefclient`.
We will very much resemble what we think is useful about Brackets, e.g., extensions to control
Menubars, etc.


Prerequisites
-------------

We use bundler to manage gems needed by some rake tasks.

```bash
$ sudo gem install bundler
```

Setup a local gem bundle:

```bash
$ bundle install --path vendor/bundle
```

