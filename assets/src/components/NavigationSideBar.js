import React from 'react'
// import PropTypes from 'prop-types'
import styled from 'styled-components'
import { NavLink } from 'react-router-dom'
import SalesLoftLogo from '@images/salesloft-logo-white.svg'
import { listPath, okrDetailPath } from '@utils/navigationUtil'
import { SIDEBAR_WIDTH } from '@utils/sidebarUtil'
import { UserContext } from '@components/UserContext'

const StyledIcon = styled(SalesLoftLogo)`
  padding: 20px 10px;
  width: 160px;
`

const SidebarWrapper = styled.aside`
  flex: 0 ${SIDEBAR_WIDTH};
  height: 100%;
  max-height: 100%;
  min-width: ${SIDEBAR_WIDTH};

  color: #fff;
  font-weight: 200;
  transition-duration: 0.2s, 0.2s, 0.35s;
  background-color: #0d163a;
`

const SidebarList = styled.div`
  display: flex;
  flex-direction: column;
  background-color: #0d163a;
  height: calc(100vh - 64px);
  overflow: auto;
  padding: unset;
  list-style: none;
`

const NavigationLink = styled(NavLink)`
  width: 100%;
  padding: 20px 30px;
  font-size: 14px;
  color: #fff;
  text-decoration: none;

  &:hover,
  &:focus {
    color: black;
    background: white;
    text-decoration: none;
  }
`

export const NavigationSideBar = () => (
  <SidebarWrapper>
    <StyledIcon />
    <SidebarList>
      <NavigationLink to={listPath()}>OKR Directory</NavigationLink>

      <UserContext.Consumer>
        {me => (
          <NavigationLink to={okrDetailPath(me.slug)}>My OKRs</NavigationLink>
        )}
      </UserContext.Consumer>
    </SidebarList>
  </SidebarWrapper>
)

NavigationSideBar.propTypes = {}
