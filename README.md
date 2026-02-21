# homebrew-ecmwf

Homebrew packages of ECMWF software

These are updated formulae (source only) for the ECMWF software packages. 
The original formulae are available in the [ecmwf/homebrew-ecmwf](https://github.com/ecmwf/homebrew-ecmwf) repository.

## Usage

`brew install jhardenberg/ecmwf/<formula>`

Or

```
brew tap jhardenberg/ecmwf
brew install <formula>
```

For fdb you will need to install ecbuild, exkti, metkit and fdb itself (they should be pulled as dependencies).

To install from sources you will need an updated version of XCode.

## Packages

- ecbuild 3.13.1
- eckit 1.29.3
- metkit 1.13.1
- fdb 5.17.3
- atlas 0.33.0
- odc 1.4.6
