#!/bin/bash

show_help() {
    echo "🚀 N8N Management Script"
    echo "======================="
    echo "Usage: ./n8n.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start     - Start N8N"
    echo "  stop      - Stop N8N"
    echo "  restart   - Restart N8N"
    echo "  status    - Show status"
    echo "  logs      - Show logs"
    echo "  backup    - Create backup"
    echo "  help      - Show this help"
}

case "$1" in
    start)
        ./start.sh
        ;;
    stop)
        ./stop.sh
        ;;
    restart)
        ./restart.sh
        ;;
    status)
        ./status.sh
        ;;
    logs)
        ./logs.sh
        ;;
    backup)
        ./backup.sh
        ;;
    help|*)
        show_help
        ;;
esac