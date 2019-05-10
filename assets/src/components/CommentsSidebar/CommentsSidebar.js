import React from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'

const SidebarWrapper = styled.aside`
  display: ${p => (p.isOpen ? 'block' : 'none')};
  height: 100%;
  margin-left: 20px;
  width: ${p => (p.isOpen ? '300px' : 0)};
  color: #fff;
  font-weight: 200;
  transition-duration: 0.2s, 0.2s, 0.35s;
  background-color: #fff;
  border-left: 1px solid #efefef;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.15),
    0 1px 5px rgba(0, 0, 0, 0.075);
`

export const CommentsSidebar = ({ isOpen }) => (
  <SidebarWrapper isOpen={isOpen}>
    <h1>Comments Sidebar</h1>
  </SidebarWrapper>
)

CommentsSidebar.propTypes = {
  isOpen: PropTypes.bool.isRequired,
}
