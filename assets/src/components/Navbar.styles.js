import styled from 'styled-components'
import { Navbar, NavItem, NavDropdown, MenuItem } from 'react-bootstrap'

export const OkrNavbar = styled(Navbar)`
  background: #fff;
  width: 100%;

  .container {
    margin: 0;
    margin-right: 0;
    margin-left: 0;
    width: 100%;
  }

  @media (max-width: 768px) {
    .navbar-collapse {
      background: #fff;
    }
  }
`

export const OkrNavHeader = styled(Navbar.Header)`
  display: flex;
  align-items: center;
`

export const OkrNavItem = styled(NavItem)``

export const OkrNavBrand = styled(Navbar.Brand)`
  color: #3a3a3a;
  font-family: 'Montserrat', sans-serif;
  font-size: 20px;
  font-weight: 500;
`

export const OkrNavDropdown = styled(NavDropdown)``

export const OkrNavMenuItem = styled(MenuItem)``
