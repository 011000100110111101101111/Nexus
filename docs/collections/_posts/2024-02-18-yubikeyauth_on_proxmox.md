---
layout: post
title: Using Yubikey for 2FA with Proxmox
date: 2024-02-16
summary: Covers setting up yubikey as a 2fa method for proxmox
categories: guides
---

**Guide results**

- Be able to use yubikey as 2FA auth for proxmox

**Prerequisites**

- Have a proxmox machine running
- Have atleast 1 yubikey

---

First, go to [yubikeys getapikey site](upgrade.yubico.com/getapikey/).

Put in your email and then press your yubikey for the YubiKey OTP field. This will allow you to use the yubikey web services for authentication and link it to your yubikey.

**Keep the ID and Key open for the following steps**

Now, go back to your proxmox UI and make sure you click on the `Datacenter` level, not the node level. Then, go to the following `Permissions -> Realms`. Now, double click the pam entry, and change `Require TFA` to `Yubico`, you will be asked for the ID and Key from the previous step so enter them here. You dont need anything for the URL, you can press enter.

Finally, while still on the `Datacenter` level, go to `Permissions -> Two Factor`. Now, press `Add -> Yubico OTP` choose the user you want this for, put any description, then press your Yubikey for the Yubico OTP Key field. You are done!

You can add more than 1 Yubikey now using the direct step above, you do not need to do the realm token again.
