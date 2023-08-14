#!/usr/bin/env bash

initial_directory=$( pwd )

script_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $script_directory

alias_line="alias maraschino=$script_directory/maraschino.sh"
bashrc=~/.bashrc

function initialize {
    echo "Adding 'maraschino' alias to your '~/.bashrc'..."
    echo $alias_line >> $bashrc

    source $bashrc

    echo "You may now use the 'maraschino' command to run this script."
}

grep -xqF -- "$alias_line" "$bashrc" || initialize

echo "Downloading environment variables..."

wget --quiet -O .env --no-check-certificate 'https://docs.google.com/uc?export=download&id=10TBAK2AiAso_yghL2k1TXOtiSMlWfs-c'

while read -r line; do
    export ${line//\n}
done < ./.env

if [[ $# -eq 0 ]] || [[ $1 == 'help' ]]; then
    echo "Usage 1: maraschino [command]"
    echo "Commands:"
    echo "    help....Show this help message"
    echo "    sql.....Open database psql shell"
    echo "    down....Stop all containers"
    echo "Usage 2: maraschino [profile] [command]"
    echo "Profiles:"
    echo "    frontend..........Frontend server"
    echo "    backend...........Backend and database server"
    echo "General Commands:"
    echo "    dev-up............Start profile in development mode"
    echo "    lint..............Run formatter and linter"
    echo "    bash..............Open bash shell"
    echo "Backend-specific Commands:"
    echo "    migration-generate [date in yyyy-mm-dd]..........Generate a new migration"
    echo "    migration-run....................................Run all migrations"
    echo "    migration-revert.................................Revert the last migration"
    echo "    seed [file-name].................................Seed the database in accordance to the specified file"
    echo "    openapi-generate.................................Generate OpenAPI specification"
elif [[ $1 == 'sql' ]]; then
    docker exec -it maraschino-database psql -U $POSTGRES_USER
elif [[ $1 == 'down' ]]; then
    docker-compose -f docker-compose.yml down
elif [[ $1 == 'frontend' ]] || [[ $1 == 'backend' ]]; then
    if [[ $# -eq 1 ]] || [[ $2 == 'dev-up' ]]; then
        if [[ $1 == 'frontend' ]]; then
            docker-compose -f docker-compose.yml --profile frontend up
        elif [[ $1 == 'backend' ]]; then
            docker-compose -f docker-compose.yml --profile backend up
        fi
    elif [[ $2 == 'lint' ]]; then
        if [[ $1 == 'frontend' ]]; then
            docker exec -it maraschino-frontend npx prettier --write /app/src/
            docker exec -it maraschino-frontend npx eslint --ext .js,.jsx,.ts,.tsx /app/src/ --fix
        elif [[ $1 == 'backend' ]]; then
            docker exec -it maraschino-backend npx prettier --write /app/src/
            docker exec -it maraschino-backend npx eslint --ext .js,.jsx,.ts /app/src/ --fix
        fi
    elif [[ $2 == 'bash' ]]; then
        if [[ $1 == 'frontend' ]]; then
            docker exec -it maraschino-frontend bash
        elif [[ $1 == 'backend' ]]; then
            docker exec -it maraschino-backend bash
        fi
    elif [[ $1 == 'backend' ]]; then
        if [[ $2 == 'migration-generate' ]]; then
            docker exec -it maraschino-backend npx ts-node ./node_modules/.bin/typeorm migration:generate ./src/orm/migrations/migration-$3 --pretty --dataSource ./src/orm/data-source.ts
        elif [[ $2 == 'migration-run' ]]; then
            docker exec -it maraschino-backend npx ts-node ./node_modules/typeorm/cli.js migration:run --dataSource ./src/orm/data-source.ts
        elif [[ $2 == 'migration-revert' ]]; then
            docker exec -it maraschino-backend npx ts-node ./node_modules/typeorm/cli.js migration:revert --dataSource ./src/orm/data-source.ts
        elif [[ $2 == 'seed' ]]; then
            docker exec -it maraschino-backend npx ts-node ./src/orm/seeds/$3.ts
        elif [[ $2 == 'openapi-generate' ]]; then
            docker exec -it maraschino-backend sh scripts/generate-openapi.sh
            cp "backend/src/types/openapi-generated.ts" "frontend/src/types/openapi-generated.ts"
        fi
    fi
fi

sudo chown -R $USER:$USER $script_directory

cd $initial_directory
