#!/bin/sh
# Xcode Cloud post-clone script
# 1. Génère les fichiers xcconfig à partir des variables d'environnement
# 2. Installe XcodeGen et regénère CoachingSage.xcodeproj (bootstrap initial — garantit cohérence project.yml ↔ xcodeproj)
# 3. Lance le script check-copie-identique pour détecter un drift inter-apps Sage

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# 1. xcconfig depuis Xcode Cloud secrets
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
