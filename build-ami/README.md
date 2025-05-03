how to build the image

> [!NOTE]
> Make sure you update the `ssh_keys/key.pub`

```bash
packer init image.pkr.hcl

packer build image.pkr.hcl
```