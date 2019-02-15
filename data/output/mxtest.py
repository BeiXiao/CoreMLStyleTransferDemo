import mxnet as mx

print(mx.test_utils.list_gpus())

a = mx.nd.ones((2, 3), mx.gpu())
b = a * 2 + 1

print(b.asnumpy())
print('list gups')
print( mx.test_utils.list_gpus())
print('Done')
