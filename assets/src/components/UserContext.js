import React, { Component, createContext } from 'react'

export const UserContext = createContext({})

export default ({ children, user }) => (
  <UserContext.Provider value={user}>{children}</UserContext.Provider>
)
