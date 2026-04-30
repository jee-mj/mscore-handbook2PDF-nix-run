# MuseScore handbook to PDF

Generate the MuseScore 3 handbook PDF in Australian English with Nix:

```sh
nix run github:jee-mj/mscore-handbook2PDF-nix-run
```

The command writes `MuseScore-3-handbook-en-AU.pdf` to the directory where it
was run.

To choose another output path:

```sh
nix run github:jee-mj/mscore-handbook2PDF-nix-run -- ./handbook.pdf
```

The MuseScore site serves the English handbook from the `en` path. The output is
named `en-AU` for the Australian English build.
