let methodStr = (method: Fetch.requestMethod) => {
  switch method {
  | Get => "GET"
  | Head => "HEAD"
  | Post => "POST"
  | Put => "PUT"
  | Delete => "DELETE"
  | Connect => "CONNECT"
  | Options => "OPTIONS"
  | Trace => "TRACE"
  | Patch => "PATCH"
  | _ => ""
  }
}
let useUrlPrefix = () => {
  ""
}

let stripV4 = path => {
  switch path {
  | list{"v4", ...remaining} => remaining
  | _ => path
  }
}

// parse a string into json and return optional json
let safeParseOpt = st => {
  try {
    Js.Json.parseExn(st)->Some
  } catch {
  | _e => None
  }
}
// parse a string into json and return json with null default
let safeParse = st => {
  safeParseOpt(st)->Belt.Option.getWithDefault(Js.Json.null)
}

type numericComparisionType =
  | LessThan(int, bool)
  | GreaterThan(int, bool)
  | EqualTo(array<int>)

type numericConditionCheck = {key: string, validRules: array<numericComparisionType>}
type conditionCheck = {key: string, vals: array<string>, not: bool}

type condition =
  | NoCondition
  | NumericCondition(numericConditionCheck)
  | ComparisionCheck(conditionCheck)

type rec logics = Return(array<(int, array<string>)>) | IfElse(array<logic>)
and logic = {
  condition: condition,
  logics: logics,
}

let getDictFromJsonObject = json => {
  switch json->Js.Json.decodeObject {
  | Some(dict) => dict
  | None => Js.Dict.empty()
  }
}

let removeDuplicate = (arr: array<string>) => {
  arr->Js.Array2.filteri((item, i) => {
    arr->Js.Array2.indexOf(item) === i
  })
}

let sortBasedOnPriority = (sortArr: array<string>, priorityArr: array<string>) => {
  let finalPriorityArr = priorityArr->Js.Array2.filter(val => sortArr->Js.Array2.includes(val))
  let filteredArr = sortArr->Js.Array2.filter(item => !(finalPriorityArr->Js.Array2.includes(item)))
  finalPriorityArr->Js.Array2.concat(filteredArr)
}
let toCamelCase = str => {
  let strArr = str->Js.String2.replaceByRe(%re("/[-_]+/g"), " ")->Js.String2.split(" ")
  strArr
  ->Js.Array2.mapi((item, i) => {
    let matchFn = (match, _, _, _, _, _) => {
      if i == 0 {
        match->Js.String2.toLocaleLowerCase
      } else {
        match->Js.String2.toLocaleUpperCase
      }
    }
    item->Js.String2.unsafeReplaceBy3(%re("/(?:^\w|[A-Z]|\b\w)/g"), matchFn)
  })
  ->Js.Array2.joinWith("")
}
let getNameFromEmail = email => {
  email
  ->Js.String2.split("@")
  ->Js.Array2.unsafe_get(0)
  ->Js.String2.split(".")
  ->Js.Array2.map(name => {
    if name == "" {
      name
    } else {
      name->Js.String2.get(0)->Js.String2.toUpperCase ++ name->Js.String2.sliceToEnd(~from=1)
    }
  })
  ->Js.Array2.joinWith(" ")
}

let getOptionString = (dict, key) => {
  dict->Js.Dict.get(key)->Belt.Option.flatMap(Js.Json.decodeString)
}

let getString = (dict, key, default) => {
  getOptionString(dict, key)->Belt.Option.getWithDefault(default)
}

let getStringFromJson = (json: Js.Json.t, default) => {
  json->Js.Json.decodeString->Belt.Option.getWithDefault(default)
}

let getBoolFromJson = (json, defaultValue) => {
  json->Js.Json.decodeBoolean->Belt.Option.getWithDefault(defaultValue)
}

let getArrayFromJson = (json: Js.Json.t, default) => {
  json->Js.Json.decodeArray->Belt.Option.getWithDefault(default)
}

let getOptionalArrayFromDict = (dict, key) => {
  dict->Js.Dict.get(key)->Belt.Option.flatMap(Js.Json.decodeArray)
}

let getArrayFromDict = (dict, key, default) => {
  dict->getOptionalArrayFromDict(key)->Belt.Option.getWithDefault(default)
}

let getArrayDataFromJson = (json, itemToObjMapper) => {
  open Belt.Option

  json
  ->Js.Json.decodeArray
  ->getWithDefault([])
  ->Belt.Array.keepMap(Js.Json.decodeObject)
  ->Js.Array2.map(itemToObjMapper)
}
let getStrArray = (dict, key) => {
  dict
  ->getOptionalArrayFromDict(key)
  ->Belt.Option.getWithDefault([])
  ->Belt.Array.map(json => json->Js.Json.decodeString->Belt.Option.getWithDefault(""))
}

let getStrArrayFromJsonArray = jsonArr => {
  jsonArr->Belt.Array.keepMap(Js.Json.decodeString)
}

let getStrArryFromJson = arr => {
  arr
  ->Js.Json.decodeArray
  ->Belt.Option.map(getStrArrayFromJsonArray)
  ->Belt.Option.getWithDefault([])
}

let getOptionStrArrayFromJson = json => {
  json->Js.Json.decodeArray->Belt.Option.map(getStrArrayFromJsonArray)
}

let getStrArrayFromDict = (dict, key, default) => {
  dict
  ->Js.Dict.get(key)
  ->Belt.Option.flatMap(getOptionStrArrayFromJson)
  ->Belt.Option.getWithDefault(default)
}

let getOptionStrArrayFromDict = (dict, key) => {
  dict->Js.Dict.get(key)->Belt.Option.flatMap(getOptionStrArrayFromJson)
}

let getNonEmptyString = str => {
  if str === "" {
    None
  } else {
    Some(str)
  }
}

let getNonEmptyArray = arr => {
  if arr->Js.Array2.length === 0 {
    None
  } else {
    Some(arr)
  }
}

let getOptionBool = (dict, key) => {
  dict->Js.Dict.get(key)->Belt.Option.flatMap(Js.Json.decodeBoolean)
}

let getBool = (dict, key, default) => {
  getOptionBool(dict, key)->Belt.Option.getWithDefault(default)
}

let getJsonObjectFromDict = (dict, key) => {
  dict->Js.Dict.get(key)->Belt.Option.getWithDefault(Js.Json.object_(Js.Dict.empty()))
}

let getBoolFromString = (boolString, default: bool) => {
  switch boolString->Js.String2.toLowerCase {
  | "true" => true
  | "false" => false
  | _ => default
  }
}
let getStringFromBool = boolValue => {
  switch boolValue {
  | true => "true"
  | false => "false"
  }
}
let getIntFromString = (str, default) => {
  switch str->Belt.Int.fromString {
  | Some(int) => int
  | None => default
  }
}
let getOptionIntFromString = str => {
  str->Belt.Int.fromString
}

let getOptionFloatFromString = str => {
  str->Belt.Float.fromString
}

let getFloatFromString = (str, default) => {
  switch str->Belt.Float.fromString {
  | Some(floatVal) => floatVal
  | None => default
  }
}

let getIntFromJson = (json, default) => {
  switch json->Js.Json.classify {
  | JSONString(str) => getIntFromString(str, default)
  | JSONNumber(floatValue) => floatValue->Belt.Float.toInt
  | _ => default
  }
}
let getOptionIntFromJson = json => {
  switch json->Js.Json.classify {
  | JSONString(str) => getOptionIntFromString(str)
  | JSONNumber(floatValue) => Some(floatValue->Belt.Float.toInt)
  | _ => None
  }
}
let getOptionFloatFromJson = json => {
  switch json->Js.Json.classify {
  | JSONString(str) => getOptionFloatFromString(str)
  | JSONNumber(floatValue) => Some(floatValue)
  | _ => None
  }
}

let getFloatFromJson = (json, default) => {
  switch json->Js.Json.classify {
  | JSONString(str) => getFloatFromString(str, default)
  | JSONNumber(floatValue) => floatValue
  | _ => default
  }
}

let getInt = (dict, key, default) => {
  switch Js.Dict.get(dict, key) {
  | Some(value) => getIntFromJson(value, default)
  | None => default
  }
}
let getOptionInt = (dict, key) => {
  switch Js.Dict.get(dict, key) {
  | Some(value) => getOptionIntFromJson(value)
  | None => None
  }
}

let getOptionFloat = (dict, key) => {
  switch Js.Dict.get(dict, key) {
  | Some(value) => getOptionFloatFromJson(value)
  | None => None
  }
}

let getFloat = (dict, key, default) => {
  dict
  ->Js.Dict.get(key)
  ->Belt.Option.map(json => getFloatFromJson(json, default))
  ->Belt.Option.getWithDefault(default)
}

let getObj = (dict, key, default) => {
  dict
  ->Js.Dict.get(key)
  ->Belt.Option.flatMap(Js.Json.decodeObject)
  ->Belt.Option.getWithDefault(default)
}

let getDictFromUrlSearchParams = searchParams => {
  open Belt.Array
  searchParams
  ->Js.String2.split("&")
  ->keepMap(getNonEmptyString)
  ->keepMap(keyVal => {
    let splitArray = Js.String2.split(keyVal, "=")

    switch (splitArray->get(0), splitArray->get(1)) {
    | (Some(key), Some(val)) => Some(key, val)
    | _ => None
    }
  })
  ->Js.Dict.fromArray
}
let setOptionString = (dict, key, optionStr) =>
  optionStr->Belt.Option.mapWithDefault((), str => dict->Js.Dict.set(key, str->Js.Json.string))

let setOptionBool = (dict, key, optionInt) =>
  optionInt->Belt.Option.mapWithDefault((), bool => dict->Js.Dict.set(key, bool->Js.Json.boolean))

let setOptionArray = (dict, key, optionArray) =>
  optionArray->Belt.Option.mapWithDefault((), array => dict->Js.Dict.set(key, array->Js.Json.array))

let setOptionDict = (dict, key, optionDictValue) =>
  optionDictValue->Belt.Option.mapWithDefault((), value =>
    dict->Js.Dict.set(key, value->Js.Json.object_)
  )

let capitalizeString = str => {
  Js.String2.toUpperCase(Js.String2.charAt(str, 0)) ++ Js.String2.substringToEnd(str, ~from=1)
}

let snakeToCamel = str => {
  str
  ->Js.String2.split("_")
  ->Js.Array2.mapi((x, i) => i == 0 ? x : capitalizeString(x))
  ->Js.Array2.joinWith("")
}

let camelToSnake = str => {
  str
  ->capitalizeString
  ->Js.String2.replaceByRe(%re("/([a-z0-9A-Z])([A-Z])/g"), "$1_$2")
  ->Js.String2.toLowerCase
}

let camelCaseToTitle = str => {
  str->capitalizeString->Js.String2.replaceByRe(%re("/([a-z0-9A-Z])([A-Z])/g"), "$1 $2")
}

let isContainingStringLowercase = (text, searchStr) => {
  text->Js.String2.toLowerCase->Js.String2.includes(searchStr->Js.String2.toLowerCase)
}

let snakeToTitle = str => {
  str
  ->Js.String2.split("_")
  ->Js.Array2.map(x => {
    let first = x->Js.String2.charAt(0)->Js.String2.toUpperCase
    let second = x->Js.String2.substringToEnd(~from=1)
    first ++ second
  })
  ->Js.Array2.joinWith(" ")
}

let titleToSnake = str => {
  str->Js.String2.split(" ")->Js.Array2.map(Js.String2.toLowerCase)->Js.Array2.joinWith("_")
}

let getIntFromString = (str, default) => {
  str->Belt.Int.fromString->Belt.Option.getWithDefault(default)
}

let removeTrailingZero = (numeric_str: string) => {
  numeric_str->Belt.Float.fromString->Belt.Option.getWithDefault(0.)->Belt.Float.toString
}

let shortNum = (
  ~labelValue: float,
  ~numberFormat: CurrencyFormatUtils.currencyFormat,
  ~presision: int=2,
  (),
) => {
  open CurrencyFormatUtils
  let value = Js.Math.abs_float(labelValue)

  switch numberFormat {
  | IND =>
    switch value {
    | v if v >= 1.0e+7 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+7, ~digits=presision)->removeTrailingZero}Cr`
    | v if v >= 1.0e+5 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+5, ~digits=presision)->removeTrailingZero}L`
    | v if v >= 1.0e+3 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+3, ~digits=presision)->removeTrailingZero}K`
    | _ => Js.Float.toFixedWithPrecision(labelValue, ~digits=presision)->removeTrailingZero
    }
  | USD | DefaultConvert =>
    switch value {
    | v if v >= 1.0e+9 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+9, ~digits=presision)->removeTrailingZero}B`
    | v if v >= 1.0e+6 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+6, ~digits=presision)->removeTrailingZero}M`
    | v if v >= 1.0e+3 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+3, ~digits=presision)->removeTrailingZero}K`
    | _ => Js.Float.toFixedWithPrecision(labelValue, ~digits=presision)->removeTrailingZero
    }
  }
}

let latencyShortNum = (~labelValue: float, ~includeMilliseconds=?, ()) => {
  if labelValue !== 0.0 {
    let value = Belt.Int.fromFloat(labelValue)
    let value_days = value / 86400
    let years = value_days / 365
    let months = mod(value_days, 365) / 30
    let days = mod(mod(value_days, 365), 30)
    let hours = value / 3600
    let minutes = mod(value, 3600) / 60
    let seconds = mod(mod(value, 3600), 60)

    let year_disp = if years >= 1 {
      `${Js.String2.make(years)}Y `
    } else {
      ""
    }
    let month_disp = if months > 0 {
      `${Js.String2.make(months)}M `
    } else {
      ""
    }
    let day_disp = if days > 0 {
      `${Js.String2.make(days)}D `
    } else {
      ""
    }
    let hr_disp = if hours > 0 {
      `${Js.String2.make(hours)}H `
    } else {
      ""
    }
    let min_disp = if minutes > 0 {
      `${Js.String2.make(minutes)}M `
    } else {
      ""
    }
    let millisec_disp = if (
      (labelValue < 1.0 ||
        (includeMilliseconds->Belt.Option.getWithDefault(false) && labelValue < 60.0)) &&
        labelValue > 0.0
    ) {
      `.${Js.String2.make(mod((labelValue *. 1000.0)->Belt.Int.fromFloat, 1000))}`
    } else {
      ""
    }
    let sec_disp = if seconds > 0 {
      `${Js.String2.make(seconds)}${millisec_disp}S `
    } else {
      ""
    }

    if days > 0 {
      year_disp ++ month_disp ++ day_disp
    } else {
      year_disp ++ month_disp ++ day_disp ++ hr_disp ++ min_disp ++ sec_disp
    }
  } else {
    "0"
  }
}

let checkEmptyJson = json => {
  json == Js.Json.object_(Js.Dict.empty())
}

let numericArraySortComperator = (a, b) => {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

let isEmptyDict = dict => {
  dict->Js.Dict.keys->Js.Array2.length === 0
}
let stringReplaceAll = (str, old, new) => {
  str->Js.String2.split(old)->Js.Array2.joinWith(new)
}

let getUniqueArray = (arr: array<'t>) => {
  arr->Js.Array2.map(item => (item, ""))->Js.Dict.fromArray->Js.Dict.keys
}

let getFirstLetterCaps = (str, ~splitBy="-", ()) => {
  str
  ->Js.String2.toLowerCase
  ->Js.String2.split(splitBy)
  ->Js.Array2.map(capitalizeString)
  ->Js.Array2.joinWith(" ")
}

let getDictfromDict = (dict, key) => {
  dict->getJsonObjectFromDict(key)->getDictFromJsonObject
}

let checkLeapYear = year => (mod(year, 4) === 0 && mod(year, 100) !== 0) || mod(year, 400) === 0

let getValueFromArr = (arr, index, default) =>
  arr->Belt.Array.get(index)->Belt.Option.getWithDefault(default)

let isEqualStringArr = (arr1, arr2) => {
  let arr1 = arr1->getUniqueArray
  let arr2 = arr2->getUniqueArray
  let lengthEqual = arr1->Js.Array2.length === arr2->Js.Array2.length
  let isContainsAll = arr1->Js.Array2.reduce((acc, str) => {
    arr2->Js.Array2.includes(str) && acc
  }, true)
  lengthEqual && isContainsAll
}

let getDefaultNumberFormat = () => {
  open CurrencyFormatUtils
  USD
}

let indianShortNum = labelValue => {
  shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat(), ())
}

let convertNewLineSaperatedDataToArrayOfJson = text => {
  text
  ->Js.String2.split("\n")
  ->Js.Array2.filter(item => item !== "")
  ->Js.Array2.map(item => {
    item->safeParse
  })
}

let getObjectArrayFromJson = json => {
  json->getArrayFromJson([])->Js.Array2.map(getDictFromJsonObject)
}

let getListHead = (~default="", list) => {
  list->Belt.List.head->Belt.Option.getWithDefault(default)
}

let dataMerge = (~dataArr: array<array<Js.Json.t>>, ~dictKey: array<string>) => {
  let finalData = Js.Dict.empty()
  dataArr->Js.Array2.forEach(jsonArr => {
    jsonArr->Js.Array2.forEach(jsonObj => {
      let dict = jsonObj->getDictFromJsonObject
      let dictKey =
        dictKey
        ->Js.Array2.map(
          ele => {
            dict->getString(ele, "")
          },
        )
        ->Js.Array2.joinWith("-")
      let existingData = finalData->getObj(dictKey, Js.Dict.empty())->Js.Dict.entries
      let data = dict->Js.Dict.entries

      finalData->Js.Dict.set(
        dictKey,
        existingData->Js.Array2.concat(data)->Js.Dict.fromArray->Js.Json.object_,
      )
    })
  })

  finalData->Js.Dict.values
}

let getJsonFromStr = data => {
  if data !== "" {
    Js.Json.stringifyWithSpace(safeParse(data), 2)
  } else {
    data
  }
}

//Extract Exn to Dict
external toExnJson: exn => Js.Json.t = "%identity"

let compareLogic = (firstValue, secondValue) => {
  let (temp1, _) = firstValue
  let (temp2, _) = secondValue
  if temp1 == temp2 {
    0
  } else if temp1 > temp2 {
    -1
  } else {
    1
  }
}

let getJsonFromArrayOfJson = arr => arr->Js.Dict.fromArray->Js.Json.object_

let getTitle = name => {
  name
  ->Js.String2.toLowerCase
  ->Js.String2.split("_")
  ->Js.Array2.map(capitalizeString)
  ->Js.Array2.joinWith(" ")
}

// Regex to check if a string contains a substring
let regex = (positionToCheckFrom, searchString) => {
  let searchStringNew =
    searchString
    ->Js.String2.replaceByRe(%re("/[<>\[\]';|?*\\]/g"), "")
    ->Js.String2.replaceByRe(%re("/\(/g"), "\\(")
    ->Js.String2.replaceByRe(%re("/\+/g"), "\\+")
    ->Js.String2.replaceByRe(%re("/\)/g"), "\\)")
  Js.Re.fromStringWithFlags(
    "(.*)(" ++ positionToCheckFrom ++ "" ++ searchStringNew ++ ")(.*)",
    ~flags="i",
  )
}

let checkStringStartsWithSubstring = (~itemToCheck, ~searchText) => {
  let isMatch = switch Js.String2.match_(itemToCheck, regex("\\b", searchText)) {
  | Some(_) => true
  | None => Js.String2.match_(itemToCheck, regex("_", searchText))->Belt.Option.isSome
  }
  isMatch && searchText->Js.String2.length > 0
}

let listOfMatchedText = (text, searchText) => {
  switch Js.String2.match_(text, regex("\\b", searchText)) {
  | Some(r) => r->Array.sliceToEnd(~start=1)->Belt.Array.keepMap(x => x)
  | None =>
    switch Js.String2.match_(text, regex("_", searchText)) {
    | Some(a) => a->Array.sliceToEnd(~start=1)->Belt.Array.keepMap(x => x)
    | None => [text]
    }
  }
}
