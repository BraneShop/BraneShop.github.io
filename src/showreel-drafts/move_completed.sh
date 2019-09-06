#!/bin/bash
rg "draft: draft" --files-without-match | xargs -I {} mv "{}" ../showreel/
