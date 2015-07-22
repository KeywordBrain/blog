---
title: Understanding and Building a GraphQL Server
author: david
description: >
  Explanations for the lesser understood parts of the GraphQL spec
summary: >
  We dive into the lesser understood parts of the GraphQL spec and
  explain how they affect your server implementation.
---

If you are trying to build a GraphQL server today, you don’t have much
choice: You pretty much have to use the reference implementation
[graphql-js]. The problem is, though, that there is almost no
documentation for it, yet.

  [graphql-js]: https://github.com/graphql/graphql-js

GraphQL has created quite some hype which led to a lot of pseudo code and
speculation flying around. We tried to build a GraphQL server with
graphql-js and will release an example project soon. However, we thought
we would share our findings right now, so others don’t have to dig in
the source code themselves.

First of all, we want to point you to the excellent articles at
[mugli/learning-graphql][learning-gql] by [@mugli][mugli-gh]. Chapters
are being added over time, so this collection will only get better. If
you want to start learning GraphQL, look no further.

  [learning-gql]: https://github.com/mugli/learning-graphql
  [mugli-gh]: https://github.com/mugli

So, here are some things we wished someone had emphasised or explicitly
stated:


## A GraphQL server has _one schema_.

The canonical way to resolve a GraphQL query is as follows, where
`query` is the GraphQL query *string*:

<script src="https://gist.github.com/mxlje/80545ec28a7841ce2411.js?file=result.js"></script>

The fact that a) you have to supply the schema to the `graphql` function
here and b) all the examples call it something relatively specific like
`BlogSchema` led us to believe that there could potentially be multiple
schemas. We would then also need a method of choosing which schema to
use based on the contents of the request, which of course led to more
confusion, as there should only be a single endpoint.

So, a GraphQL server has a single schema.


## This schema has _one query_ and/or _one mutation_ parameter.

The values for these two parameters are `GraphQLObjectType`s. We
will get to what that means in just a second. Because a mutation is
basically a “query with side effects”, from here on we will only talk
about `query`.

<script src="https://gist.github.com/mxlje/80545ec28a7841ce2411.js?file=schema.js"></script>

The `RootQuery` is just an ordinary `GraphQLObjectType`. This kind of
type has a `name` and `fields` property and each field can have a
`type`, `args` and a `resolve` function property. Hence, you construct
your schema for both query and mutation by nesting GraphQL types. The
`RootQuery` is thus just the top-most GraphQL type, but per-se nothing
special.

This did surprise us, because we were under the impression that you
could have multiple root types, as some earlier articles suggested.
Well, you cannot — any more. In fact, the GraphQL spec evolved to only
allow one root type per operation (query or mutation), but it used to
allow multiple root types. Now, all your client-side queries need to
fit into this one GraphQL type (respectively it’s fields).


## The `name` you give to your root GraphQL type is arbitrary.

Because there is only one root type, it really doesn’t matter what name
you give to it. We call it `Query` by convention.

<script src="https://gist.github.com/mxlje/80545ec28a7841ce2411.js?file=rootquery.js"></script>


## Fields on the root type are your “public API”.

_Update:_ [@dschafer] expanded the GraphQL README to better explain this
in [PR #66][pr].

  [@dschafer]: https://github.com/dschafer
  [pr]: https://github.com/facebook/graphql/pull/66

The only way to access or mutate data is by accessing fields of the
root (i.e. top-most) GraphQL type. Let’s say you constructed the
following schema:

<script src="https://gist.github.com/mxlje/80545ec28a7841ce2411.js?file=publicapi.js"></script>


This is a mouth-full. What is happening here? The `RootQuery` defines
only one field, namely `article` of type `BlogArticle` with an argument
called `id`. The `BlogArticle` type is — like `RootQuery` — a
`GraphQLObjectType`. It, again, defines fields, among others, the
`author` field of type `BlogAuthor`. And now we finally get down to
the lowest level, as the fields on `BlogAuthor` are all GraphQL
primitives.

Now notice that — in this setup — you cannot access an author directly.
The only way to access this type and its fields is via the `article`
field on the `RootQuery` type. This is why you could consider the root
type your public API.

If you wanted to expose the authors directly, you’d need to add an
author field (possibly with args like `id`) to the `fields` object of
the `RootQuery`. Please note that in the example above the `article`
function fetches an article object that has an `author` property. It
implicitly fetches the author when fetching the article. If you added
an `author` field to the `RootQuery`, this field would also need a
resolve function that fetches the required author data.


## A `resolve()` function can return a `Promise`.

In case you are wondering how the `article` function above goes about
its business of fetching an article from a database, the key is that
you can call any function inside `resolve` that either returns your
required data or a Promise, which eventually resolves with said data.
This allows you to make the necessary async calls to your storage backend.


## You should start using named queries.

Named queries are generally optional, but have a couple of benefits.
For example, the following two queries are equivalent

<script src="https://gist.github.com/mxlje/80545ec28a7841ce2411.js?file=named.js"></script>

but here is why you should start to name your queries:

First, you can have multiple named queries per document. Now, while you
only send one query per request, having multiple named queries in one
document allows you to put them all in one `.graphql` file. Second,
only named queries allow the use of variables, e.g.:

<script src="https://gist.github.com/mxlje/80545ec28a7841ce2411.js?file=namedvariables.js"></script>

If you send this query along with the variable `$someId` in the arguments,
the actual query is assembled on the server, avoiding string concatenation
on the client. 

This is not only less of a burden on the client, but also more secure,
as you can no longer run into injection security vulnerabilities.

In `graphql-js` these arguments are supplied as the fourth argument to
the graphql function:

<script src="https://gist.github.com/mxlje/80545ec28a7841ce2411.js?file=arguments.js"></script>

You would typically need to get these `arguments` from the http request or
whatever other transport your particular server implementation is using.
A spec for graphql-http is currently being codified.

---

We hope this article shed some light on the so far lesser understood
parts of the spec and how they affect the server implementations. We plan
on using GraphQL quite heavily for KeywordBrain and will continue to
document our findings here. In the meantime, you should follow [@davidpfahler]
and [@mxlje] on Twitter.

  [@davidpfahler]: https://twitter.com/davidpfahler
  [@mxlje]: https://twitter.com/mxlje

We’d also like to thank [Dan Schafer][dschafer] and everybody in the
[GraphQL Slack channel][slack] for their feedback on this post and
answering questions about the nitty gritty details.

  [dschafer]: https://github.com/dschafer
  [slack]: https://graphql-slack.herokuapp.com
