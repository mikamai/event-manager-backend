# Mikamai Event Manager

Mikamai's event management system, used by us as well as many communities around the world to gather and meet up. Publicly available at meetable.it.

## Design

Event Manager is a [Phoenix](http://www.phoenixframework.org/) application that exposes a [GraphQL API](https://graphql.org/) for managing events and participations.

Authentication and Authorization rely on two [OAuth 2.0](https://auth0.com/docs/protocols/oauth2) protocols, [OpenID Connect 1.0](https://auth0.com/docs/protocols/oidc) and [User-Managed Access 2.0](https://wso2.com/library/article/2018/12/a-quick-guide-to-user-managed-access-2-0/). OpenID is used for authenticating users and give them access to their own events and participations through OAuth 2.0 scopes, while UMA 2 is used to manage sharing permission over a group of users (for example, multiple organizers managing a group).

Any compatible provider should work, but the public instance for Meetable uses [Keycloak](https://keycloak.org/), so this is what it is most tested against.

## Quickstart

### Docker Compose

Supporting services such as PostgreSQL and Keycloak can be started as Docker containers.  
Simply running `docker-compose up -d` will start them in background and expose port `5432` for Postgres and `8080` for Keycloak. The application is preconfigured to use them.

### Run

Classic Phoenix procedures:

```bash
# Install dependencies
mix deps.get

# Prepare the database schema

mix ecto.migrate

# Start the app

mix phx.server
```

The app will be available on port 4000.

## GraphQL Clients

The recommended GraphQL client to use when developing the API is [Insomnia](http://insomnia.rest), as it has first class support for both GraphQL and OAuth 2.0.

Other good clients are [GraphQL Playground](https://github.com/prisma-labs/graphql-playground) and [Altair](https://altair.sirmuel.design/), but you need to manually provide OAuth 2.0 tokens as the `Authorization` header, with `Bearer` scheme.

If you don't wish to install a desktop application, or there are none available for your system, a web version of GraphQL Playground is available at https://localhost:4000/graphql/explorer.

## Grafical Clients

The official web client for Meetable is available on [GitHub](https://github.com/mikamai/event-manager-frontend).
