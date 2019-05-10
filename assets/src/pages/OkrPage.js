import React, { Component } from 'react'
import styled from 'styled-components'
import { Navbar, Nav } from 'react-bootstrap'
import { Helmet } from 'react-helmet'
import _ from 'lodash'

import { Analytics, Group, Okr, User } from '@utils/api'
import { CommentsSidebar } from '@components/CommentsSidebar/CommentsSidebar'
import {
  OkrNavbar,
  OkrNavHeader,
  OkrNavItem,
  OkrNavBrand,
  OkrNavDropdown,
  OkrNavMenuItem,
} from '@components/Navbar.styles'
import { OkrPanel } from '@components/OkrPanel/OkrPanel'
import { PageContent } from '@components/PageComponents'
import AddOkrForm from '@components/AddOkrForm'
import ObjectiveLinkingState from '@components/State/ObjectiveLinking'
import { UserContext } from '@components/UserContext'

const OkrPageWrapper = styled.div`
  display: flex;
  flex-wrap: nowrap;
  height: 100%;
`

const OkrPageBody = styled(PageContent)`
  display: flex;
  flex-wrap: nowrap;
  flex: 1;
`

const OkrFormWrapper = styled('div')`
  width: 50%;

  @media (max-width: 768px) {
    width: 100%;
  }
`

const INITIAL_STATE = {
  commentsSidebarOpen: false,
  addOkr: false,
  viewReport: undefined,
  okrs: undefined,
  group: undefined,
  user: undefined,
}

export default class OkrPage extends Component {
  state = INITIAL_STATE

  componentDidMount() {
    this.loadData()
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    if (prevProps.slug !== this.props.slug) {
      this.resetState()
      this.loadData()
    }
  }

  resetState() {
    this.setState(INITIAL_STATE)
  }

  afterOkrCreated = () => {
    this.setState({ addOkr: false, okrs: undefined })
    this.loadData()
  }

  loadData() {
    const { type } = this.props

    if (type === 'user') {
      return User.findBySlug(this.props.slug).then(user => {
        Okr.forUser(user).then(okrs => {
          this.setState({ user, okrs: this.wrapOkrs(okrs) })
        })

        this.getViewReport(user.id)
      })
    } else if (type === 'group') {
      return Group.findBySlug(this.props.slug).then(group => {
        Okr.forGroup(group).then(okrs => {
          this.setState({ group, okrs: this.wrapOkrs(okrs) })
        })

        this.getViewReport(group.id)
      })
    }
  }

  getViewReport(ownerId) {
    Analytics.getOkrViewReport(ownerId).then(viewReport => {
      this.setState({ viewReport })
    })
  }

  toggleSidebar = () => {
    this.setState({
      commentsSidebarOpen: !this.state.commentsSidebarOpen,
    })
  }

  toggleOkr = () => {
    this.setState({
      addOkr: !this.state.addOkr,
    })
  }

  wrapOkrs(okrs) {
    return okrs.map(okr => ({
      ...okr,
      keyResultCreated: () => this.loadData(),
      keyResultUpdated: () => this.loadData(),
      objectiveCreated: () => this.loadData(),
      objectiveUpdated: () => this.loadData(),
      objectiveAssessmentCreated: () => this.loadData(),
      objectiveAssessmentUpdated: () => this.loadData(),
      objectiveLinkCreated: () => this.loadData(),
      objectiveLinkDeleted: () => this.loadData(),
      okrReflectionCreated: () => this.loadData(),
      okrReflectionUpdated: () => this.loadData(),
    }))
  }

  renderNavBar(owner, addOkr) {
    return (
      <OkrNavbar collapseOnSelect>
        <OkrNavHeader>
          <OkrNavBrand>{owner && owner.name}</OkrNavBrand>
          <Navbar.Toggle />
        </OkrNavHeader>
        <Navbar.Collapse>
          <Nav pullRight>
            {this.state.viewReport ? (
              <OkrNavItem>
                {this.state.viewReport.distinct_okr_views_30_days} unique views
                last 30 days
              </OkrNavItem>
            ) : null}
            <OkrNavItem eventKey={1} onClick={this.toggleOkr}>
              { addOkr ? 'Cancel' : 'Add OKR' }
            </OkrNavItem>
          </Nav>
        </Navbar.Collapse>
      </OkrNavbar>
    )
  }

  showAddOkr(currentUser, okrUser, okrs) {
    if (!okrUser || !okrs) {
      return false
    }

    return (
      currentUser.id === okrUser.id &&
      okrs.filter(okr => okr.cycle.active).length === 0
    )
  }

  render() {
    const { addOkr, commentsSidebarOpen, okrs, group, user } = this.state
    const okrOwner = user || group

    return (
      <UserContext.Consumer>
        {currentUser => (
          <OkrPageWrapper>
            {okrOwner ? (
              <Helmet>
                <title>{`OKR | ${okrOwner.name} | SalesLoft OKRs`}</title>
              </Helmet>
            ) : null}

            <OkrPageBody>
              {this.renderNavBar(okrOwner, addOkr)}
              {addOkr || this.showAddOkr(currentUser, user, okrs) ? (
                <OkrFormWrapper>
                  <AddOkrForm
                    activeCycles={getActiveCycles(okrs)}
                    afterCreate={this.afterOkrCreated}
                    ownerParams={ownerParams(group, user)}
                  />
                </OkrFormWrapper>
              ) : null}
              <ObjectiveLinkingState>
                <div>
                  {(okrs || []).map(okr => (
                    <OkrPanel key={okr.id} okr={okr} />
                  ))}
                </div>
              </ObjectiveLinkingState>
            </OkrPageBody>
            <CommentsSidebar isOpen={commentsSidebarOpen} />
          </OkrPageWrapper>
        )}
      </UserContext.Consumer>
    )
  }
}

function getActiveCycles(okrs) {
  return (okrs || []).map(okr => okr.cycle)
}

function ownerParams(group, user) {
  if (group) {
    return { group_id: group.id }
  } else if (user) {
    return { user_id: user.id }
  }

  return {}
}
