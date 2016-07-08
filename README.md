# syn-core
Base libs for syn modules: events, dom builders, helpers, translations...


## Services

### Messaging
`MesssagingUiInterface` is provided to allow any external lib to create and set global ui messaging service.

```js
//my-ui-service.es
import core from 'syn-core'

class MyUiMessagingService extends core.messaging.ui.interface

  confirm () {
    window.alert(options.title)
  }

```

```js

//index.es
import { Messaging } from 'syn-core'
import MyUiMessagingService from './my-ui-service'

Messaging.getInstance().setUIService(new MyUiMessagingService() )

```
