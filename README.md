Substance-Shell
===============

This project provides a Rake driven configuration to create a native application on top of
node-webkit.

Disclaimer: Under construction.

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

The shell expects you to pull in your application into `app`

```bash
$ ln -s ../composer app
```

Bundle
------

```bash
$ rake setup bundle
```

> Note: `rake setup` downloads and extracts `node-webkit` for your platform. This is only needed the
  first time.

Clean
-----

To remove the generated bundle do

```bash
$ rake clean
```

To even remove downloaded files do

```bash
$ rake clean:all
```

To suggest a feature, report a bug, or general discussion: http://github.com/substance/substance/issues/
