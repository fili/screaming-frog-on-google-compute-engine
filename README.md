

# screaming-frog-on-google-compute-engine
Screaming Frog SEO Spider Install Script by Fili (SEO Expert &amp; ex-Google engineer)

Installation Guide:
https://searchengineland.com/how-to-run-screaming-frog-seo-spider-in-the-cloud-in-2019-317416

## To run

```
./gce-sf.sh
```

## Options

The -b option will prompt for the URL of the Screaming Frog SEO Spider package to install. This can be a beta or historic version.

```
./gce-sf.sh -b
```

The -r option will remove any current installation of Screaming Frog SEO Spider and disable the swap file.

```
./gce-sf.sh -r
```

Options can be combined.

```
./gce-sf.sh -r -b
```
