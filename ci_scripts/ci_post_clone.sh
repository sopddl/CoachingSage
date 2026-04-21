#!/bin/sh
# Xcode Cloud post-clone script
# Génère les fichiers xcconfig à partir des secrets Xcode Cloud.
# Le .xcodeproj est versionné — pas besoin de XcodeGen sur CI.
# check-copie-identique.sh est local only (apps Sage = repos Git séparés).

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cat > "${REPO_DIR}/Config-Debug.xcconfig" << EOF
SUPABASE_HOST = ${SUPABASE_HOST}
SUPABASE_ANON_KEY = ${SUPABASE_ANON_KEY}
EOF

cat > "${REPO_DIR}/Config-Staging.xcconfig" << EOF
SUPABASE_HOST = ${SUPABASE_HOST}
SUPABASE_ANON_KEY = ${SUPABASE_ANON_KEY}
EOF

cat > "${REPO_DIR}/Config-Release.xcconfig" << EOF
SUPABASE_HOST = ${SUPABASE_HOST}
SUPABASE_ANON_KEY = ${SUPABASE_ANON_KEY}
EOF

echo "✅ xcconfig files generated"
