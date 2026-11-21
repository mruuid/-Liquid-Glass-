#!/usr/bin/env bash
set -euo pipefail

REPOSITORY="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is not set}"
WORKSPACE="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is not set}"
PUBLIC_DIR="$WORKSPACE/public"

sudo apt-get update
sudo apt-get install -y dpkg-dev apt-utils xz-utils

mkdir -p "$PUBLIC_DIR/debs"

mapfile -t RELEASE_TAGS < <(
  gh release list --repo "$REPOSITORY" --limit 100 \
    --json tagName,isDraft,isPrerelease \
    --jq '.[] | select(.isDraft == false and .isPrerelease == false) | .tagName'
)

if [ "${#RELEASE_TAGS[@]}" -eq 0 ]; then
  echo "No published GitHub releases were found." >&2
  exit 1
fi

for tag in "${RELEASE_TAGS[@]}"; do
  echo "Downloading .deb assets from $tag"
  gh release download "$tag" --repo "$REPOSITORY" \
    --pattern '*.deb' --dir "$PUBLIC_DIR/debs"
done

shopt -s nullglob
PACKAGES=( "$PUBLIC_DIR"/debs/*.deb )
if [ "${#PACKAGES[@]}" -eq 0 ]; then
  echo "No Debian packages were downloaded." >&2
  exit 1
fi

cat > "$WORKSPACE/Release.header" <<'EOF'
Origin: mruuid
Label: Liquid Glass 26
Suite: stable
Codename: stable
Architectures: iphoneos-arm64
Components: main
Description: Rootless Liquid Glass packages for Dopamine, Sileo and Zebra
EOF

(
  cd "$PUBLIC_DIR"

  dpkg-scanpackages --multiversion debs /dev/null > Packages
  gzip -n -9c Packages > Packages.gz
  bzip2 -9c Packages > Packages.bz2
  xz -9e -c Packages > Packages.xz

  # Generate checksums before Release exists, avoiding a self-referential hash.
  apt-ftparchive release . > "$WORKSPACE/Release.checksums"
  cat "$WORKSPACE/Release.header" "$WORKSPACE/Release.checksums" > Release
  rm -f "$WORKSPACE/Release.checksums"

  grep -q '^Package: com.mruuid.liquidglass26
cat > "$PUBLIC_DIR/index.html" <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Liquid Glass 26 APT Repository</title>
  <style>
    :root { color-scheme: dark; }
    body { margin: 0; padding: 48px 20px; background: #101319; color: #f4f6fb; font: 16px/1.6 -apple-system, BlinkMacSystemFont, sans-serif; }
    main { max-width: 760px; margin: auto; padding: 32px; border: 1px solid #343b49; border-radius: 24px; background: #191f2b; }
    h1 { margin-top: 0; letter-spacing: -.04em; }
    code { display: block; overflow-wrap: anywhere; padding: 14px; border-radius: 12px; background: #0c1017; color: #b9d9ff; }
    a { color: #9cc8ff; }
    .muted { color: #aab4c5; }
  </style>
</head>
<body>
  <main>
    <h1>Liquid Glass 26</h1>
    <p class="muted">Rootless APT repository for Dopamine · Sileo · Zebra</p>
    <h2>Add this source</h2>
    <code>https://raw.githubusercontent.com/mruuid/-Liquid-Glass-/gh-pages/</code>
    <p>Open Sileo or Zebra, choose Sources → Add Source, and paste the URL above.</p>
    <p><a href="./Packages.gz">Packages.gz</a> · <a href="./Packages.xz">Packages.xz</a> · <a href="./Release">Release metadata</a></p>
    <p class="muted">Packages are built for rootless jailbreak environments. Check firmware and dependencies before installing.</p>
    <p><a href="https://github.com/mruuid/-Liquid-Glass-/releases">GitHub Releases</a> · <a href="https://github.com/mruuid/-Liquid-Glass-">Source code</a></p>
  </main>
</body>
</html>
EOF

git -C "$PUBLIC_DIR" init -b gh-pages
git -C "$PUBLIC_DIR" config user.name "github-actions[bot]"
git -C "$PUBLIC_DIR" config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git -C "$PUBLIC_DIR" add --all
git -C "$PUBLIC_DIR" commit -m "Publish APT repository"
git -C "$PUBLIC_DIR" remote add origin "https://x-access-token:${GH_TOKEN}@github.com/$REPOSITORY.git"
git -C "$PUBLIC_DIR" push --force origin gh-pages

echo "APT repository published: https://raw.githubusercontent.com/$REPOSITORY/gh-pages/"
 Packages
  grep -q '^Version: 0.3.0
cat > "$PUBLIC_DIR/index.html" <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Liquid Glass 26 APT Repository</title>
  <style>
    :root { color-scheme: dark; }
    body { margin: 0; padding: 48px 20px; background: #101319; color: #f4f6fb; font: 16px/1.6 -apple-system, BlinkMacSystemFont, sans-serif; }
    main { max-width: 760px; margin: auto; padding: 32px; border: 1px solid #343b49; border-radius: 24px; background: #191f2b; }
    h1 { margin-top: 0; letter-spacing: -.04em; }
    code { display: block; overflow-wrap: anywhere; padding: 14px; border-radius: 12px; background: #0c1017; color: #b9d9ff; }
    a { color: #9cc8ff; }
    .muted { color: #aab4c5; }
  </style>
</head>
<body>
  <main>
    <h1>Liquid Glass 26</h1>
    <p class="muted">Rootless APT repository for Dopamine · Sileo · Zebra</p>
    <h2>Add this source</h2>
    <code>https://raw.githubusercontent.com/mruuid/-Liquid-Glass-/gh-pages/</code>
    <p>Open Sileo or Zebra, choose Sources → Add Source, and paste the URL above.</p>
    <p><a href="./Packages.gz">Packages.gz</a> · <a href="./Packages.xz">Packages.xz</a> · <a href="./Release">Release metadata</a></p>
    <p class="muted">Packages are built for rootless jailbreak environments. Check firmware and dependencies before installing.</p>
    <p><a href="https://github.com/mruuid/-Liquid-Glass-/releases">GitHub Releases</a> · <a href="https://github.com/mruuid/-Liquid-Glass-">Source code</a></p>
  </main>
</body>
</html>
EOF

git -C "$PUBLIC_DIR" init -b gh-pages
git -C "$PUBLIC_DIR" config user.name "github-actions[bot]"
git -C "$PUBLIC_DIR" config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git -C "$PUBLIC_DIR" add --all
git -C "$PUBLIC_DIR" commit -m "Publish APT repository"
git -C "$PUBLIC_DIR" remote add origin "https://x-access-token:${GH_TOKEN}@github.com/$REPOSITORY.git"
git -C "$PUBLIC_DIR" push --force origin gh-pages

echo "APT repository published: https://raw.githubusercontent.com/$REPOSITORY/gh-pages/"
 Packages
  grep -q '^SHA256:' Packages
  if grep -Eq ' [0-9]+ Release
cat > "$PUBLIC_DIR/index.html" <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Liquid Glass 26 APT Repository</title>
  <style>
    :root { color-scheme: dark; }
    body { margin: 0; padding: 48px 20px; background: #101319; color: #f4f6fb; font: 16px/1.6 -apple-system, BlinkMacSystemFont, sans-serif; }
    main { max-width: 760px; margin: auto; padding: 32px; border: 1px solid #343b49; border-radius: 24px; background: #191f2b; }
    h1 { margin-top: 0; letter-spacing: -.04em; }
    code { display: block; overflow-wrap: anywhere; padding: 14px; border-radius: 12px; background: #0c1017; color: #b9d9ff; }
    a { color: #9cc8ff; }
    .muted { color: #aab4c5; }
  </style>
</head>
<body>
  <main>
    <h1>Liquid Glass 26</h1>
    <p class="muted">Rootless APT repository for Dopamine · Sileo · Zebra</p>
    <h2>Add this source</h2>
    <code>https://raw.githubusercontent.com/mruuid/-Liquid-Glass-/gh-pages/</code>
    <p>Open Sileo or Zebra, choose Sources → Add Source, and paste the URL above.</p>
    <p><a href="./Packages.gz">Packages.gz</a> · <a href="./Packages.xz">Packages.xz</a> · <a href="./Release">Release metadata</a></p>
    <p class="muted">Packages are built for rootless jailbreak environments. Check firmware and dependencies before installing.</p>
    <p><a href="https://github.com/mruuid/-Liquid-Glass-/releases">GitHub Releases</a> · <a href="https://github.com/mruuid/-Liquid-Glass-">Source code</a></p>
  </main>
</body>
</html>
EOF

git -C "$PUBLIC_DIR" init -b gh-pages
git -C "$PUBLIC_DIR" config user.name "github-actions[bot]"
git -C "$PUBLIC_DIR" config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git -C "$PUBLIC_DIR" add --all
git -C "$PUBLIC_DIR" commit -m "Publish APT repository"
git -C "$PUBLIC_DIR" remote add origin "https://x-access-token:${GH_TOKEN}@github.com/$REPOSITORY.git"
git -C "$PUBLIC_DIR" push --force origin gh-pages

echo "APT repository published: https://raw.githubusercontent.com/$REPOSITORY/gh-pages/"
 Release; then
    echo "Release must not contain a checksum for itself." >&2
    exit 1
  fi
)
rm -f "$WORKSPACE/Release.header"

cat > "$PUBLIC_DIR/index.html" <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Liquid Glass 26 APT Repository</title>
  <style>
    :root { color-scheme: dark; }
    body { margin: 0; padding: 48px 20px; background: #101319; color: #f4f6fb; font: 16px/1.6 -apple-system, BlinkMacSystemFont, sans-serif; }
    main { max-width: 760px; margin: auto; padding: 32px; border: 1px solid #343b49; border-radius: 24px; background: #191f2b; }
    h1 { margin-top: 0; letter-spacing: -.04em; }
    code { display: block; overflow-wrap: anywhere; padding: 14px; border-radius: 12px; background: #0c1017; color: #b9d9ff; }
    a { color: #9cc8ff; }
    .muted { color: #aab4c5; }
  </style>
</head>
<body>
  <main>
    <h1>Liquid Glass 26</h1>
    <p class="muted">Rootless APT repository for Dopamine · Sileo · Zebra</p>
    <h2>Add this source</h2>
    <code>https://raw.githubusercontent.com/mruuid/-Liquid-Glass-/gh-pages/</code>
    <p>Open Sileo or Zebra, choose Sources → Add Source, and paste the URL above.</p>
    <p><a href="./Packages.gz">Packages.gz</a> · <a href="./Packages.xz">Packages.xz</a> · <a href="./Release">Release metadata</a></p>
    <p class="muted">Packages are built for rootless jailbreak environments. Check firmware and dependencies before installing.</p>
    <p><a href="https://github.com/mruuid/-Liquid-Glass-/releases">GitHub Releases</a> · <a href="https://github.com/mruuid/-Liquid-Glass-">Source code</a></p>
  </main>
</body>
</html>
EOF

git -C "$PUBLIC_DIR" init -b gh-pages
git -C "$PUBLIC_DIR" config user.name "github-actions[bot]"
git -C "$PUBLIC_DIR" config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git -C "$PUBLIC_DIR" add --all
git -C "$PUBLIC_DIR" commit -m "Publish APT repository"
git -C "$PUBLIC_DIR" remote add origin "https://x-access-token:${GH_TOKEN}@github.com/$REPOSITORY.git"
git -C "$PUBLIC_DIR" push --force origin gh-pages

echo "APT repository published: https://raw.githubusercontent.com/$REPOSITORY/gh-pages/"
