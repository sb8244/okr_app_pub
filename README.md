# OkrApp

## TODO

- [x] Write readme for Get Started
- [x] Add enterprise schema handling for `department` and `manager` attributes
  - [x] Write
  - [x] Display
- [x] Switch out in memory User for DB user
- [x] Objective model
- [x] KeyResult model
- [x] Group model
- [ ] Audit log model
- [ ] OkrAnalytics model
- [x] Pull Pete's work in
- [x] Frontend: Show group OKR (like user)
- [x] Frontend: OKRs Creation
  - [x] Create a new OKR inside of a cycle
    - [x] OKR form
    - [x] API connected
  - [x] Create objective under an OKR
    - [x] Objective form
    - [x] API connected
  - [x] Create KR under an objective
    - [x] KR form
    - [x] API connected
- [x] Frontend: KeyResult
  - [X] Set scores
    - [x] Form
    - [x] API
  - [x] Cancel
  - [x] Update
  - [x] Delete
- [x] My OKRs link
- [x] Frontend: Objective
  - [x] Update
  - [x] Cancel
  - [x] Delete
  - [x] Link to other objectives
- [ ] Create Group (Add current user)
- [ ] Disable forms when processing
- [ ] Handle form errors
- [ ] Cancel forms
- [ ] Support long objectives / key result text on frontend
- [ ] Comments
  - [ ] Frontend
    - [ ] Comments are on the Objective level (not user / group level)
  - [ ] Backend

## Short list

- [x] number of people in the system compared to those who have objective in current cycle (percentage + raw)
- [x] logged in last 7 days
- [x] profile views (total, unique)
- [x] quick copy paste for a single objective (3 pastes for 3 objectives)
- [x] 4 key result default
- [x] refactor linking to not show begin/save depending on if the linking process is started
- [x] Message when linking starts
- [ ] Create new group

## Bugs / less important

- [x] Validate not null columns on update, even if they aren't required attributes (required if present)

## Get started

To start your Phoenix server:

  1. `mix deps.get`
  2. `mix ecto.create && mix ecto.migrate`
  3. `cd assets && npm install && cd ..`
  4. `mix phx.server`

Now you can visit [`https://localhost.salesloft.com:6007`](https://localhost.salesloft.com:6007) from your browser.

## Seeds

You can seed some starter data. If you want to use an Okta login, you'll need to set it up properly. It's recommended
to fake the login locally for this reason.

```
mix ecto.reset && mix run priv/seed.exs
```

## Fake Login

You can fake login (in dev env only), by hitting the following URL:

```
https://okrs.devsalesloft.com:6007/force_login?user_name=steve.bussey%2Bdev@salesloft.com
```

You can change the user_name parameter to anything in the `priv/seed.exs` file.

## Codeship

Codeship is used to test this application (shipping handled in some additional config). However, you don't
need a codeship account to benefit from this! If you download the Codeship `jet` tool, you can run `jet steps`
to run the test suite in a self-contained format.

## Deploy to Docker (Maintainers only)

```
export TAG=version
docker build . -t salesloft/okr-app:$TAG && docker push salesloft/okr-app:$TAG
```

## SalesLoft Specific Checklist

These things we'd want to remove if ever open-sourcing this code.

- [ ] OKR Playbook link (AddObjective.js)
- [ ] Local HTTPS URL
- [ ] SL Logo
- [ ] SalesLoft in titles
- [ ] SalesLoft mailer URL
- [ ] Okta failure screen (samly_pipeline.ex)
