require! <[colors prettyjson]>

COLORIZED = (v) ->
  t = typeof v
  return v.yellow if t is \string
  return v.to-string! .green if t is \number
  return v.to-string! .magenta if t is \boolean and v
  return v.to-string! .red if t is \boolean and not v
  return (JSON.stringify v).blue if t is \object
  return v

PRETTIZE_KVS = (kvs, separator=", ") ->
  xs = [ "#{k.gray}:#{COLORIZED v}" for k, v of kvs ]
  return xs.join separator

PRINT_PRETTY_JSON = (name, config, idents=1, output=console.error) ->
  return output "#{name}: \n#{(JSON.stringify config, null, ' ').gray}" unless prettyjson?
  text = prettyjson.render config, do
    keysColor: \gray
    dashColor: \green
    stringColor: \yellow
    numberColor: \cyan
    defaultIndentation: 4
    inlineArrays: yes
  xs = text.split '\n'
  tabs = "\t" * idents
  output "#{name}:"
  [ output "#{tabs}#{x}" for x in xs ]
  output ""

module.exports = exports = {COLORIZED, PRETTIZE_KVS, PRINT_PRETTY_JSON}
