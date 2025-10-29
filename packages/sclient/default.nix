{ pkgs }:

pkgs.writeShellScriptBin "sclient" ''
  ADDRESS=$1
  
  if [ -z "$ADDRESS" ]; then
    echo "Usage: sclient <hostname:port>"
    echo ""
    echo "Display SSL/TLS certificate information for a given host and port."
    echo "Shows certificate validity dates, subject, issuer, and SANs."
    echo ""
    echo "Examples:"
    echo "  sclient google.com        # defaults to port 443"
    echo "  sclient google.com:443    # explicit port"
    exit 1
  fi
  
  # Parse hostname and port from ADDRESS
  if [[ "$ADDRESS" == *":"* ]]; then
    HOST=$(echo "$ADDRESS" | cut -d: -f1)
    PORT=$(echo "$ADDRESS" | cut -d: -f2)
    FULL_ADDRESS="$ADDRESS"
  else
    HOST="$ADDRESS"
    PORT=443
    FULL_ADDRESS="$ADDRESS:443"
  fi
  
  ${pkgs.openssl}/bin/openssl s_client -connect "$FULL_ADDRESS" -servername "$HOST" </dev/null 2>/dev/null \
    | ${pkgs.openssl}/bin/openssl x509 -noout -dates -subject -issuer -ext subjectAltName
''
