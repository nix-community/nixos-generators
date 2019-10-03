# Remote installation ISO

Create a bootable ISO which provides remote access
via a hidden tor service.

```
+-------------+   i am 12345.onion   +-------------+
|             +<---------------------+             |
| controlling |                      | controlled  |
| computer    |   ssh 12345.onion    | computer    |
|             +--------------------->+    +--------++
+-------------+                      +----+USB stick|
                                          +---------+
```

## Details

The **controlling computer** runs a hidden tor service,
and listens on 1337 via netcat.

The **controlled computer** is the one that uses the
ISO. It starts also a hidden tor service and connects
to the **controlling computer** to inform it about
about the **controlled computers** hidden tor service
domain.

Once you know the hidden tor service domain of the **controlled computer**
You can ssh into it and do what every you want in there,
for example install NixOS.

## What do you need

* Install a hidden tor service on your **controlling computer** (use `remote-service.nix` for that)
* Create the ISO and put it on a hardware device (e.g.: USB)
* Both computers need internet access (obviously)

## Files

* `./config.nix` : to generate the ISO
* `./remote-service.nix` : to setup the hidden tor service on your **controlling computer**.

## Steps

* Import `./remote-service.nix` in your `/etc/nixos/configuration.nix` and run `nixos-rebuild switch`
* Set `publiSshKey` in `./config.nix`
* Set `hiddenReceiver` in `./config.nix` using  `remote-install-get-hiddenReceiver` 
* Run `nixos-generate -f install-iso -c ./config.nix`
* Prepare the USB stick : `sudo if=<path of the iso> of=/dev/<device> bs=4096`
* Boot the USB stick on your **controlled computer**
* Run `remote-install-start-service` on your **controlling computer**
* After some time `remote-install-start-service` will print the ssh command to login into the **controlled computer**.

Now you can do the normal installations procedure via ssh.
