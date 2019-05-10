import React, { Component } from 'react'
import { NavLink } from 'react-router-dom'
import { debounce, flatten, groupBy } from 'lodash'
import styled from 'styled-components'

import { Button } from 'react-bootstrap'
import { PageContent } from '@components/PageComponents'

import { Analytics, Group, User } from '@utils/api'
import { okrDetailPath, okrGroupDetailPath } from '@utils/navigationUtil'

const SearchInput = styled.input`
  font-size: 1.4rem;
  margin-bottom: 20px;
  padding: 0.5rem;
  width: 60%;
`

const SearchResults = styled.div`
  width: 65%;
`

const SearchResultName = styled.div`
  display: inline;
  font-size: 1.3em;
  margin-right: 5px;
`

let ToggleButton = styled.div`
  display: inline-block;
  margin-left: 10px;
`

const OkrDetailLink = styled(NavLink)`
  color: inherit;
  text-decoration: none;
`

let SearchResult = ({ className, group, user }) => {
  if (user) {
    return (
      <div className={className}>
        <OkrDetailLink to={okrDetailPath(user.slug)}>
          <SearchResultName>{user.name}</SearchResultName>
          &nbsp;
          <small>{user.user_name}</small>
        </OkrDetailLink>
      </div>
    )
  } else if (group) {
    return (
      <div className={className}>
        <OkrDetailLink to={okrGroupDetailPath(group.slug)}>
          <SearchResultName>{group.name}</SearchResultName>
        </OkrDetailLink>
      </div>
    )
  }
}

SearchResult = styled(SearchResult)`
  margin-bottom: 20px;
  padding: 15px;
  width: 100%;

  background: white;
  border: 1px solid #ccc;
`

const ActiveUserReport = styled.div`
  flex-grow: 1;
  margin-left: 20px;
  padding: 15px;

  background: white;
  border: 1px solid #ccc;

  h4 {
    .stat {
      margin-left: 20px;
    }
  }
`

const ContentWrapper = styled.div`
  display: flex;
  align-items: flex-start;
`

export class ListPage extends Component {
  state = {
    groupResults: [],
    pinnedGroupResults: [],
    userResults: [],
    activeUserReport: undefined,
    searchTerm: '',
    showGroupResults: true,
    showUserResults: true,
  }

  constructor(props) {
    super(props)

    this.initiateSearch = debounce(this.initiateSearch, 500)
  }

  componentDidMount() {
    this.fetchUsers()
    this.fetchGroups()
    this.fetchActiveUser()
  }

  fetchActiveUser() {
    Analytics.getActiveUserReport().then(activeUserReport => {
      this.setState({ activeUserReport })
    })
  }

  fetchGroups(search) {
    Group.search(search || '').then(groupResults => {
      const { true: pinnedGroupResults, false: unpinnedResults } = groupBy(
        groupResults,
        'pinned'
      )
      this.setState({ groupResults: unpinnedResults, pinnedGroupResults })
    })
  }

  fetchUsers(search) {
    User.search(search || '').then(userResults => {
      this.setState({ userResults })
    })
  }

  initiateSearch = () => {
    const { searchTerm } = this.state

    this.fetchUsers(searchTerm)
    this.fetchGroups(searchTerm)
  }

  searchTermChange = evt => {
    this.setState({
      searchTerm: evt.target.value,
    })

    this.initiateSearch()
  }

  render() {
    const {
      searchTerm,
      groupResults,
      pinnedGroupResults,
      userResults,
      activeUserReport,
      showGroupResults,
      showUserResults,
    } = this.state
    let searchResults = []

    if (showGroupResults) {
      searchResults = searchResults.concat(
        (pinnedGroupResults || []).map(group => (
          <SearchResult key={`group-${group.id}`} group={group} />
        ))
      )
    }

    if (showUserResults) {
      searchResults = searchResults.concat(
        (userResults || []).map(user => (
          <SearchResult key={`user-${user.id}`} user={user} />
        ))
      )
    }

    if (showGroupResults) {
      searchResults = searchResults.concat(
        (groupResults || []).map(group => (
          <SearchResult key={`group-${group.id}`} group={group} />
        ))
      )
    }

    return (
      <PageContent>
        <div>
          <SearchInput
            placeholder="Search User or Group"
            value={searchTerm}
            onChange={this.searchTermChange}
          />

          <ToggleButton>
            <Button
              bsStyle={showGroupResults ? 'primary' : 'link'}
              onClick={() =>
                this.setState({ showGroupResults: !showGroupResults })
              }
            >
              {`${showGroupResults ? 'Showing' : 'Hiding'} Groups`}
            </Button>
          </ToggleButton>

          <ToggleButton>
            <Button
              bsStyle={showUserResults ? 'primary' : 'link'}
              onClick={() =>
                this.setState({ showUserResults: !showUserResults })
              }
            >
              {`${showUserResults ? 'Showing' : 'Hiding'} Users`}
            </Button>
          </ToggleButton>
        </div>

        <ContentWrapper>
          <SearchResults>{searchResults}</SearchResults>
          {activeUserReport ? (
            <ActiveUserReport>
              <h4>
                <span>Weekly active lofters</span>
                <span className="stat">
                  {activeUserReport.unique_user_count_7_days}
                </span>
                <small>
                  &nbsp;&nbsp;/ {activeUserReport.total_active_user_count}
                </small>
              </h4>
              <h4>
                <span>Lofters with active objectives</span>
                <span className="stat">
                  {activeUserReport.users_with_active_objectives_count}
                </span>
                <small>
                  &nbsp;&nbsp;
                  {percentage(
                    activeUserReport.users_with_active_objectives_count,
                    activeUserReport.total_active_user_count
                  )}
                  %
                </small>
              </h4>
            </ActiveUserReport>
          ) : null}
        </ContentWrapper>
      </PageContent>
    )
  }
}

const ONE_DECIMAL_PLACE = 10

function percentage(a, b) {
  return Math.round((a / b) * 100 * ONE_DECIMAL_PLACE) / ONE_DECIMAL_PLACE
}
