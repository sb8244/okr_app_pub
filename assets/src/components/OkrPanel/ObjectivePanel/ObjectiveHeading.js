import React, { Component } from 'react'
import styled from 'styled-components'
import { Button, FormControl } from 'react-bootstrap'
import { Objective } from '@utils/api'

import ScoringArea from './ScoringArea'
import ObjectiveActions from './ObjectiveActions';

const FormButton = styled(Button)`
  margin-top: 10px;
  margin-right: 10px;
`

const PanelHeading = styled.div`
  font-size: 20px;
  font-weight: 500;
  max-width: 70%;
  text-decoration: ${({ objective }) => objective.cancelled_at ? 'line-through' : 'none'};

  small {
    font-size: 14px;
    white-space: nowrap;
  }
`

const Wrapper = styled.div`
  display: flex;
  width: 100%;
`

const UpdateForm = styled.form`
  flex-grow: 1;

  button[type='submit'] {
    margin-top: 10px;
  }
`

export default class ObjectiveHeading extends Component {
  state = {
    editing: false,
    editingContent: ''
  }

  cancel() {
    this.setState({ editing: false })
  }

  setEditing(editing) {
    if (editing) {
      this.setState({ editingContent: this.props.objective.content })
    }

    this.setState({ editing })
  }

  updateObjective = (evt) => {
    evt.preventDefault()

    const { objective, okr } = this.props
    const { editingContent } = this.state

    Objective.update(objective.id, { content: editingContent }).then(() => {
      okr.objectiveUpdated().then(() => {
        this.setEditing(false)
      })
    })
  }

  render() {
    const { assessmentWrapper, objective, okr } = this.props
    const { editing, editingContent } = this.state

    if (editing) {
      return (
        <Wrapper>
          <UpdateForm onSubmit={this.updateObjective}>
            <FormControl
              required
              type="text"
              value={editingContent}
              onChange={(evt) => this.setState({ editingContent: evt.target.value })}
              autoFocus
            />
            <FormButton type="submit" bsClass="btn-xs btn-primary">Save</FormButton>
            <FormButton type="button" bsClass="btn-xs" onClick={() => this.cancel()}>Cancel</FormButton>
          </UpdateForm>
        </Wrapper>
      )
    } else {
      return (
        <Wrapper>
          <PanelHeading objective={objective} onClick={() => this.setEditing(true)}>{objective.content} <small>as measured by...</small></PanelHeading>
          <ObjectiveActions objective={objective} okr={okr} assessmentWrapper={assessmentWrapper} />
          <ScoringArea editable={false} midScore={`mid: ${objective.mid_score}`} finalScore={`final: ${objective.final_score}`} />
        </Wrapper>
      )
    }
  }
}
