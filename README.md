# Add Skarabox to nix-starter-configs

This repository's [commit history][] shows the steps needed to
add a [Skarabox][] host to a repository following the
[nix-starter-configs][].

The steps followed are outlined in the Skarabox manual:

1. https://installer.skarabox.com/installation.html#existing-repo
2. https://installer.skarabox.com/installation.html#vm
3. https://installer.skarabox.com/installation.html#run-installer

I could then run `nix run .#myskarabox-unlock` and unlock the VM.

[commit history]: https://github.com/ibizaman/nix-starter-configs-skarabox/commits/main/
[Skarabox]: https://github.com/ibizaman/skarabox
[nix-starter-configs]: https://github.com/Misterio77/nix-starter-configs/
