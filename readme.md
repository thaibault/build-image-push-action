<!-- #!/usr/bin/env markdown
-*- coding: utf-8 -*-
region header
Copyright Torben Sickert (info["~at~"]tsickert.com) 16.12.2012

License
-------

This library written by Torben Sickert stands under a creative commons naming
4.0 international license.
See https://creativecommons.org/licenses/by/4.0/deed.de
endregion -->

<!--|deDE:Einsatzmöglichkeiten-->
<!--|frFR:Cas d'utilisation-->
Use case
--------

A composite GitHub action which builds a container image from the
"Dockerfile" of a repository for x86-64 and arm-64 and pushes it to a
container registry, optionally to a second one as well. It takes care of the
registry login, emulation of the foreign architecture, a layer cache between
runs and the cleanup of untagged image versions.
<!--deDE:
    Eine zusammengesetzte GitHub-Action, die ein Container-Image aus dem
    "Dockerfile" eines Repositorys für x86-64 und arm-64 baut und in eine
    Container-Registry hochlädt, optional zusätzlich in eine zweite. Sie
    kümmert sich um die Anmeldung an der Registry, die Emulation der fremden
    Architektur, einen Layer-Cache zwischen den Läufen und das Aufräumen
    ungetaggter Image-Versionen.
-->
<!--frFR:
    Une action GitHub composite qui construit une image de conteneur à
    partir du "Dockerfile" d'un dépôt pour x86-64 et arm-64 et la pousse vers
    un registre de conteneurs, éventuellement aussi vers un second. Elle se
    charge de la connexion au registre, de l'émulation de l'architecture
    étrangère, d'un cache de couches entre les exécutions et du nettoyage des
    versions d'image sans tag.
-->

<div class="wd-table-of-contents">
    <h2 id="content">Content<!--deDE:Inhalt--><!--frFR:Contenu--></h2>
    <!--wd-table-of-contents-->
</div>

<!--|deDE:Verwendung-->
<!--|frFR:Utilisation-->
Usage
-----

The action checks out the repository itself, so a job only needs this one
step. The following workflow builds and pushes an image to the GitHub
container registry whenever a version tag is pushed:
<!--deDE:
    Die Action checkt das Repository selbst aus, ein Job braucht also nur
    diesen einen Schritt. Der folgende Workflow baut ein Image und lädt es in
    die GitHub-Container-Registry hoch, sobald ein Versions-Tag gepusht wird:
-->
<!--frFR:
    L'action récupère elle-même le dépôt, un job n'a donc besoin que de
    cette seule étape. Le workflow suivant construit une image et la pousse
    vers le registre de conteneurs de GitHub dès qu'un tag de version est
    poussé:
-->

```yaml
name: Build image and push

on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+'

jobs:
  main:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      packages: write

    steps:
      - uses: thaibault/build-image-push-action@main
        with:
          name: ${{ github.event.repository.name }}
          tags: ${{ github.ref_name }} latest
          description: ${{ github.event.repository.description }}

          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}
```

The image ends up as "ghcr.io/&lt;owner&gt;/&lt;repository&gt;" with the
version and "latest" as tags. "packages: write" is needed both for pushing and
for deleting old image versions.
<!--deDE:
    Das Image landet als "ghcr.io/&lt;owner&gt;/&lt;repository&gt;" mit der
    Version und "latest" als Tags. "packages: write" wird sowohl zum
    Hochladen als auch zum Löschen alter Image-Versionen benötigt.
-->
<!--frFR:
    L'image est publiée sous "ghcr.io/&lt;owner&gt;/&lt;repository&gt;" avec
    la version et "latest" comme tags. "packages: write" est nécessaire à la
    fois pour pousser et pour supprimer les anciennes versions d'image.
-->

<!--|deDE:Eingaben-->
<!--|frFR:Entrées-->
Inputs
------

<!--|deDE:Image-->
<!--|frFR:Image-->
### Image

- "name" (required): image name, the last part of the image path.<!--deDE:"name" (erforderlich): Image-Name, der letzte Teil des Image-Pfads.--><!--frFR:"name" (obligatoire): nom de l'image, la dernière partie du chemin de l'image.-->
- "tags": space separated tags, see [Tags](#tags).<!--deDE:"tags": durch Leerzeichen getrennte Tags, siehe [Tags](#tags).--><!--frFR:"tags": tags séparés par des espaces, voir [Tags](#tags).-->
- "description": description annotated to the multi-architecture image, which the GitHub package page shows. Defaults to the repository description.<!--deDE:"description": Beschreibung, mit der das Multi-Architektur-Image annotiert wird und die die GitHub-Paketseite anzeigt. Standardmäßig die Beschreibung des Repositorys.--><!--frFR:"description": description annotée sur l'image multi-architecture, affichée par la page du paquet GitHub. Par défaut, la description du dépôt.-->
- "labels": image labels, one "key=value" per line. Defaults to the OCI labels derived from the repository.<!--deDE:"labels": Image-Labels, ein "key=value" pro Zeile. Standardmäßig die aus dem Repository abgeleiteten OCI-Labels.--><!--frFR:"labels": labels de l'image, un "key=value" par ligne. Par défaut, les labels OCI dérivés du dépôt.-->

<!--|deDE:Bauen-->
<!--|frFR:Construction-->
### Build

- "architecture": "all" (default), "x86-64" or "arm-64". The architecture which does not match the runner is emulated via QEMU.<!--deDE:"architecture": "all" (Standard), "x86-64" oder "arm-64". Die Architektur, die nicht zum Runner passt, wird per QEMU emuliert.--><!--frFR:"architecture": "all" (par défaut), "x86-64" ou "arm-64". L'architecture qui ne correspond pas au runner est émulée via QEMU.-->
- "build-args": build arguments, one "NAME=value" per line.<!--deDE:"build-args": Build-Argumente, ein "NAME=value" pro Zeile.--><!--frFR:"build-args": arguments de construction, un "NAME=value" par ligne.-->
- "build-target": stage of a multi-stage "Dockerfile" to build. Defaults to the last one.<!--deDE:"build-target": zu bauende Stufe eines mehrstufigen "Dockerfile". Standardmäßig die letzte.--><!--frFR:"build-target": étape d'un "Dockerfile" multi-étapes à construire. Par défaut, la dernière.-->
- "dockerfile-path": path of the "Dockerfile", default "Dockerfile". The build context is always the repository root.<!--deDE:"dockerfile-path": Pfad des "Dockerfile", Standard "Dockerfile". Der Build-Kontext ist immer die Wurzel des Repositorys.--><!--frFR:"dockerfile-path": chemin du "Dockerfile", par défaut "Dockerfile". Le contexte de construction est toujours la racine du dépôt.-->

<!--|deDE:Cache und Aufräumen-->
<!--|frFR:Cache et nettoyage-->
### Cache and cleanup

- "use-cache": "true" (default) reuses the layers of former runs, "false" builds everything from scratch.<!--deDE:"use-cache": "true" (Standard) verwendet die Layer früherer Läufe wieder, "false" baut alles von Grund auf.--><!--frFR:"use-cache": "true" (par défaut) réutilise les couches des exécutions précédentes, "false" reconstruit tout depuis le début.-->
- "cache-key": key the layer cache is saved under, default "buildx-layer".<!--deDE:"cache-key": Schlüssel, unter dem der Layer-Cache gespeichert wird, Standard "buildx-layer".--><!--frFR:"cache-key": clé sous laquelle le cache de couches est enregistré, par défaut "buildx-layer".-->
- "cache-restore-keys": key prefixes to restore an older cache from if "cache-key" has none, default "buildx-layer".<!--deDE:"cache-restore-keys": Schlüssel-Präfixe, aus denen ein älterer Cache wiederhergestellt wird, wenn es zu "cache-key" keinen gibt, Standard "buildx-layer".--><!--frFR:"cache-restore-keys": préfixes de clé à partir desquels un cache plus ancien est restauré si "cache-key" n'en a pas, par défaut "buildx-layer".-->
- "delete-old-images": "true" (default) deletes untagged images on "ghcr.io", see [Cleanup](#cleanup).<!--deDE:"delete-old-images": "true" (Standard) löscht ungetaggte Images auf "ghcr.io", siehe [Aufräumen](#cleanup).--><!--frFR:"delete-old-images": "true" (par défaut) supprime les images sans tag sur "ghcr.io", voir [Nettoyage](#cleanup).-->

<!--|deDE:Registry-->
<!--|frFR:Registre-->
### Registry

- "registry" (required): registry host, e.g. "ghcr.io" or "docker.io".<!--deDE:"registry" (erforderlich): Host der Registry, z. B. "ghcr.io" oder "docker.io".--><!--frFR:"registry" (obligatoire): hôte du registre, par exemple "ghcr.io" ou "docker.io".-->
- "username" (required): login for the registry.<!--deDE:"username" (erforderlich): Login für die Registry.--><!--frFR:"username" (obligatoire): identifiant pour le registre.-->
- "password" (required): password or token for the registry.<!--deDE:"password" (erforderlich): Passwort oder Token für die Registry.--><!--frFR:"password" (obligatoire): mot de passe ou jeton pour le registre.-->
- "ownername": namespace of the image in the registry. Defaults to "username".<!--deDE:"ownername": Namensraum des Images in der Registry. Standardmäßig "username".--><!--frFR:"ownername": espace de noms de l'image dans le registre. Par défaut "username".-->

The image is pushed as "&lt;registry&gt;/&lt;ownername&gt;/&lt;name&gt;".
<!--deDE:
    Das Image wird als "&lt;registry&gt;/&lt;ownername&gt;/&lt;name&gt;"
    hochgeladen.
-->
<!--frFR:
    L'image est poussée sous "&lt;registry&gt;/&lt;ownername&gt;/&lt;name&gt;".
-->

<!--|deDE:Zweite Registry-->
<!--|frFR:Second registre-->
### Alternate registry

With "alternate-registry" set, every tag is pushed there as well. Each of the
other options falls back to its counterpart of the main registry:
<!--deDE:
    Ist "alternate-registry" gesetzt, wird jedes Tag zusätzlich dorthin
    hochgeladen. Jede der anderen Optionen fällt auf ihr Gegenstück der
    Haupt-Registry zurück:
-->
<!--frFR:
    Si "alternate-registry" est défini, chaque tag y est aussi poussé.
    Chacune des autres options se rabat sur son équivalent du registre
    principal:
-->

- "alternate-registry": second registry host.<!--deDE:"alternate-registry": Host der zweiten Registry.--><!--frFR:"alternate-registry": hôte du second registre.-->
- "alternate-username": login, defaults to "username".<!--deDE:"alternate-username": Login, standardmäßig "username".--><!--frFR:"alternate-username": identifiant, par défaut "username".-->
- "alternate-password": password or token, defaults to "password".<!--deDE:"alternate-password": Passwort oder Token, standardmäßig "password".--><!--frFR:"alternate-password": mot de passe ou jeton, par défaut "password".-->
- "alternate-ownername": namespace, defaults to "alternate-username", then to "ownername" and "username".<!--deDE:"alternate-ownername": Namensraum, standardmäßig "alternate-username", dann "ownername" und "username".--><!--frFR:"alternate-ownername": espace de noms, par défaut "alternate-username", puis "ownername" et "username".-->

To push to Docker Hub in addition to the GitHub container registry, add:
<!--deDE:
    Um zusätzlich zur GitHub-Container-Registry auf Docker Hub hochzuladen,
    ergänzen Sie:
-->
<!--frFR:
    Pour pousser aussi vers Docker Hub en plus du registre de conteneurs de
    GitHub, ajoutez:
-->

```yaml
          alternate-registry: docker.io
          alternate-username: ${{ secrets.DOCKERHUB_USERNAME }}
          alternate-password: ${{ secrets.DOCKERHUB_TOKEN }}
```

<!--|deDE:Details-->
<!--|frFR:Détails-->
Details
-------

### Tags

"tags" is a space separated list, each entry becomes a tag in every
registry. A tag named "main" or "master" is pushed as "latest" instead.
Without "tags", the image is tagged with the name of the branch or tag the
workflow runs for.
<!--deDE:
    "tags" ist eine durch Leerzeichen getrennte Liste, jeder Eintrag wird zu
    einem Tag in jeder Registry. Ein Tag namens "main" oder "master" wird
    stattdessen als "latest" hochgeladen. Ohne "tags" erhält das Image den
    Namen des Branches oder Tags, für den der Workflow läuft.
-->
<!--frFR:
    "tags" est une liste séparée par des espaces, chaque entrée devient un
    tag dans chaque registre. Un tag nommé "main" ou "master" est poussé
    sous "latest" à la place. Sans "tags", l'image reçoit le nom de la
    branche ou du tag pour lequel le workflow s'exécute.
-->

<!--|deDE:Cache-->
<!--|frFR:Cache-->
### Cache

The layer cache lives in the GitHub actions cache. Since an existing cache
entry is never overwritten, give each run its own "cache-key" and restore from
a common prefix:
<!--deDE:
    Der Layer-Cache liegt im GitHub-Actions-Cache. Da ein bestehender
    Cache-Eintrag nie überschrieben wird, geben Sie jedem Lauf einen eigenen
    "cache-key" und stellen Sie über ein gemeinsames Präfix wieder her:
-->
<!--frFR:
    Le cache de couches réside dans le cache des actions GitHub. Comme une
    entrée de cache existante n'est jamais écrasée, donnez à chaque exécution
    sa propre "cache-key" et restaurez à partir d'un préfixe commun:
-->

```yaml
          cache-key: ${{ runner.os }}-buildx-layer-${{ github.sha }}
          cache-restore-keys: ${{ runner.os }}-buildx-layer-
```

Images which install the latest packages on each build, e.g. scheduled
rebuilds, should set "use-cache" to "false" so that no outdated layers are
reused.
<!--deDE:
    Images, die bei jedem Bau die neuesten Pakete installieren, z. B.
    geplante Neubauten, sollten "use-cache" auf "false" setzen, damit keine
    veralteten Layer wiederverwendet werden.
-->
<!--frFR:
    Les images qui installent les derniers paquets à chaque construction, par
    exemple les reconstructions planifiées, devraient mettre "use-cache" à
    "false" afin qu'aucune couche obsolète ne soit réutilisée.
-->

<!--|deDE:Aufräumen-->
<!--|frFR:Nettoyage-->
### Cleanup

Rebuilding a tag leaves the image it replaces behind without a tag. If the
main registry is "ghcr.io", the action deletes such untagged images of the
package "name" after the build and keeps the 50 most recent ones. The
architecture specific parts of the images which are still tagged are kept.
Images in other registries are not touched.
<!--deDE:
    Ein erneuter Bau eines Tags hinterlässt das ersetzte Image ohne Tag. Ist
    die Haupt-Registry "ghcr.io", löscht die Action nach dem Bau solche
    ungetaggten Images des Pakets "name" und behält die 50 neuesten. Die
    architekturspezifischen Teile der weiterhin getaggten Images bleiben
    erhalten. Images in anderen Registrys bleiben unberührt.
-->
<!--frFR:
    Une nouvelle construction d'un tag laisse l'image qu'elle remplace sans
    tag. Si le registre principal est "ghcr.io", l'action supprime après la
    construction ces images sans tag du paquet "name" et conserve les 50
    plus récentes. Les parties spécifiques à une architecture des images qui
    ont encore un tag sont conservées. Les images des autres registres ne
    sont pas touchées.
-->
