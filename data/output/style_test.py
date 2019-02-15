import turicreate as tc
import mxnet as mx
import numpy as np
# setgup
tc.config.set_num_gpus(-1)
# Load the style and content images
styles = tc.load_images('/input/style_transfer_data/style/')
content = tc.load_images('/input/style_transfer_data/content/')
# Create a StyleTransfer model
model = tc.style_transfer.create(styles, content)
# Load some test images
test_images = tc.load_images('/input/style_transfer_data/test/')
# Stylize the test images
stylized_images = model.stylize(test_images)
# Save the model for later use in Turi Create
model.save('mymodel.model')

# Export for use in Core ML
model.export_coreml('MyStyleTransfer.mlmodel')
