import React, { Component } from 'react'
import styled from 'styled-components'
import { FormControl, Button, Panel, DropdownButton, MenuItem } from 'react-bootstrap';
import { OkrReflection } from '@utils/api'

const Add = styled.small`
  cursor: pointer;
`

const Dropdown = styled.div`
  flex-grow: 1;
  text-align: right;
`

const PanelHeader = styled.div`
  display: flex
`

const Preline = styled.div`
  white-space: pre-line;
`

const FormButton = styled(Button)`
  margin-right: 10px;
  margin-top: 10px;
`

const TextArea = styled(FormControl)`
  margin: 0 !important;
  width: auto;

  &:focus {
    border: 1px solid #ccc;
    box-shadow: none;
  }
`

const DEFAULT_QUESTIONS =
`1. Did I accomplish all of my objectives? If so, what contributed to my success? If not, what obstacles did I encounter?



2. If I were to rewrite a goal achieved in full, what would I change?



3. What have I learned that might alter my approach to the next cycle’s OKRs?

`

export default class AddOKRReflection extends Component {
  state = {
    adding: false
  }

  deleteFn(okr) {
    return () => {
      if (window.confirm('Are you sure you want to delete this? This is not reversible')) {
        const now = (new Date()).toISOString()
        OkrReflection.update(okr.okr_reflection.id, { deleted_at: now }).then(okr.okrReflectionUpdated)
      }
    }
  }

  submit(e) {
    e.preventDefault()
    const { okr } = this.props

    const params = {
      reflection: e.target.reflection.value,
      okr_id: okr.id
    }

    if (okr.okr_reflection) {
      OkrReflection.update(okr.okr_reflection.id, params).then(() => {
        this.setState({ adding: false })
        okr.okrReflectionUpdated()
      })
    } else {
      OkrReflection.create(params).then(() => {
        this.setState({ adding: false })
        okr.okrReflectionCreated()
      })
    }
  }

  render() {
    const { adding } = this.state
    const { okr } = this.props

    if (!adding && !okr.okr_reflection) {
      return (
        <div>
          <Add onClick={() => this.setState({ adding: true })}>+ OKR Reflection</Add>
        </div>
      )
    } else if (!adding && okr.okr_reflection) {
      return (
        <Panel>
          <Panel.Heading>
            <Panel.Title componentClass={PanelHeader}>
              <span>OKR Reflection</span>
              <Dropdown>
                <DropdownButton bsSize="xsmall" pullRight title="actions" id={`reflection-actions-${okr.id}`}>
                  <MenuItem onClick={this.deleteFn(okr)}>Delete reflection</MenuItem>
                </DropdownButton>
              </Dropdown>
            </Panel.Title>
          </Panel.Heading>
          <Panel.Body onClick={() => this.setState({ adding: true })}>
            <Preline>{okr.okr_reflection.reflection}</Preline>
            <p><i><a href="#" onClick={(e) => e.preventDefault()}>edit</a></i></p>
          </Panel.Body>
        </Panel>
      )
    } else {
      return (
        <Panel>
          <Panel.Heading>
            <Panel.Title>OKR Reflection</Panel.Title>
          </Panel.Heading>
        <Panel.Body>
          <p>
            A <a target="_blank" href="https://hbswk.hbs.edu/item/learning-by-thinking-how-reflection-improves-performance">Harvard Business School study</a> found that:
          </p>
          <ul>
            <li>"Learning from direct experience can be more effective if coupled with reflection-that is, the intentional attempt to synthesize, abstract, and articulate the key lessons taught by experience."</li>
            <li>"Reflecting on what has been learned makes experience more productive."</li>
            <li>"Reflection builds one's confidence in the ability to achieve a goal (i.e., self-efficacy), which in turn translates into higher rates of learning."</li>
          </ul>
          <p>
            "By three methods we may learn wisdom: First, by reflection, which is noblest; Second, by imitation, which is easiest; and third, by experience, which is the bitterest."
            <br />
            <small><i>-- Confucius</i></small>
          </p>
          <p>
            "We do not learn from experience. We learn from reflecting on experience."
            <br />
            <small><i>-- John Dewey, educator and philosopher</i></small>
          </p>
          <form onSubmit={this.submit.bind(this)}>
            <TextArea
              componentClass="textarea"
              required
              name="reflection"
              cols="120"
              rows="12"
              defaultValue={(okr.okr_reflection || {}).reflection || DEFAULT_QUESTIONS}
            />
            <FormButton type="submit" bsClass="btn-xs btn-primary">Save</FormButton>
            <FormButton type="button" bsClass="btn-xs" onClick={() => this.setState({ adding: false })}>Cancel</FormButton>
          </form>
        </Panel.Body>
        </Panel>
      )
    }
  }
}
