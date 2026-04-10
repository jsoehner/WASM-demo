#!/usr/bin/env python3
"""
Fix package-viewer.sh to add WASM verification after copying files.
"""

import re

# Read the current script
with open('package-viewer.sh', 'r') as f:
    content = f.read()

# Define the verification code
verify_code = '''

# Verify WASM files were copied (CRITICAL FOR PROPER FUNCTIONING!)
WASM_FILES=("index.html" "pkg/wasm_agent.js" "pkg/wasm_agent_bg.wasm")
for file in "${WASM_FILES[@]}"; do
    if [ ! -f "$DIST_DIR/$file" ]; then
        print_error "Critical: WASM files not found at dist/$file"
        print_error "Please run: wasm-pack build first before packaging"
        exit 1
    fi
done

print_status "✅ All WASM files verified in dist/"
'''

# Find the cp -r viewer/* line and insert verification after it
pattern = r'(cp -r viewer/\* "\$DIST_DIR/"\n)(# Create a simple web server script)'

# Insert the verification code
if 'cp -r viewer/* "$DIST_DIR/"' in content:
    new_content = re.sub(pattern, r'\1' + verify_code + r'\2', content, count=1)
    with open('package-viewer.sh', 'w') as f:
        f.write(new_content)
    print('✅ Verification code inserted successfully!')
    print()
    print('You can now rebuild the distribution with:')
    print('  ./package-viewer.sh')
else:
    print('Could not find the cp -r command. Current content snippet:')
    for line in content.split('\n'):
        if 'cp -r viewer' in line:
            print(f'  {repr(line)}')
