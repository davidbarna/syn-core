import MesssagingUiInterface from './interface'

class MesssagingUIConsole extends MesssagingUiInterface {

  confirm (options) {
    console.log('::::::MesssagingUIConsole::::::')
    console.log(options)
    console.log(':::::::::::::::::::::::::::::::')
  }
}

export default MesssagingUIConsole
