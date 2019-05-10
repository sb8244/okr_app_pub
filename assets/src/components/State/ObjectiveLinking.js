import React, { Component, createContext } from 'react'

export const ObjectiveLinkingContext = createContext({})

export default class ObjectiveLinkingState extends Component {
  state = {
    linkingCode: localStorage.linkingCode
  }

  clearLinking() {
    delete localStorage.linkingCode
    this.setState({ linkingCode: undefined })
  }

  getLinkingSourceId() {
    return new Promise((resolve, reject) => {
      const text = localStorage.linkingCode || ''
      const match = text.match(/source\-objective:(\d+)/)

      if (match && match[1]) {
        return resolve(match[1])
      } else {
        return reject('Please "Begin Linking" first.')
      }
    })
  }

  setLinking(objective) {
    const linkingCode = `source-objective:${objective.id}`
    localStorage.linkingCode = linkingCode
    this.setState({ linkingCode })
  }

  render() {
    const value = {
      linkingCode: this.state.linkingCode,
      clearLinking: this.clearLinking.bind(this),
      getLinkingSourceId: this.getLinkingSourceId.bind(this),
      setLinking: this.setLinking.bind(this)
    }

    return (
      <ObjectiveLinkingContext.Provider value={value}>
        {this.props.children}
      </ObjectiveLinkingContext.Provider>
    )
  }
}
