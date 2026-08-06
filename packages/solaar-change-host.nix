{
  fetchpatch,
  solaar,
  ...
}:

solaar.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/pwr-Solaar/Solaar/pull/3259.patch";
      hash = "sha256-vC2pCa0q7q+H4EQzYaoePS5Ao6gqzvvArsosGyALcF0=";
    })
  ];
})
