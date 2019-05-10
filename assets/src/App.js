import React, { Component } from 'react'
import styled from 'styled-components'
import { Helmet } from 'react-helmet'
import { BrowserRouter, Route, Switch, Redirect } from 'react-router-dom'
import { ThemeProvider } from 'styled-components'
import { ToastContainer } from 'react-toastify'

import { NavigationSideBar } from '@components/NavigationSideBar'
import { listPath, okrDetailPath, okrGroupDetailPath } from '@utils/navigationUtil'
import { ListPage } from '@pages/ListPage'
import OkrPage from '@pages/OkrPage'
import { theme } from '@utils/styleUtils'
import UserContext from './components/UserContext'

import 'react-toastify/dist/ReactToastify.css'

const PageContainer = styled.div`
  height: 100%;
  width: 100%;
`

const LayoutWrapper = styled.div`
  display: flex;
  height: 100%;
`

const MainContentWrapper = styled.main`
  flex-grow: 1;
  height: 100%;
  overflow: auto;
  padding: 15px;

  background: #f7f9fa;
`

class App extends Component {
  render() {
    const { currentUser } = this.props

    return (
      <UserContext user={currentUser}>
        <ThemeProvider theme={theme}>
          <BrowserRouter>
            <LayoutWrapper>
              <NavigationSideBar />
              <MainContentWrapper>{this.renderRoutes()}</MainContentWrapper>
              <ToastContainer
                hideProgressBar
              />
            </LayoutWrapper>
          </BrowserRouter>
        </ThemeProvider>
      </UserContext>
    )
  }

  renderRoutes() {
    return (
      <Switch>
        <Route
          exact
          path="/"
          render={() => <Redirect replace to={listPath()} />}
        />
        <Route
          path={listPath()}
          render={({ history, match, location }) => {
            return (
              <PageContainer>
                <Helmet>
                  <title>OKR Directory | SalesLoft OKRs</title>
                </Helmet>
                <ListPage key={location.key} />
              </PageContainer>
            )
          }}
        />
        <Route
          path={okrGroupDetailPath(':slug')}
          render={({ history, match, location }) => {
            return (
              <PageContainer>
                <Helmet>
                  <title>OKR | SalesLoft OKRs</title>
                </Helmet>
                <OkrPage key={location.key} type="group" slug={match.params.slug} />
              </PageContainer>
            )
          }}
        />
        <Route
          path={okrDetailPath(':slug')}
          render={({ history, match, location }) => {
            return (
              <PageContainer>
                <Helmet>
                  <title>OKR | SalesLoft OKRs</title>
                </Helmet>
                <OkrPage key={location.key} type="user" slug={match.params.slug} />
              </PageContainer>
            )
          }}
        />
      </Switch>
    )
  }
}

export default App
