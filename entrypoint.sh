#!/bin/bash
/bin/sed -i 's/FW_TIMEOUT/'"$FW_TIMEOUT"'/g' /opt/mergepdf.sh
exec "$@"
